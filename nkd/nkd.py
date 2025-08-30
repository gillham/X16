#!/usr/bin/env python
"""
Network Kompile Daemon (NKD) for retro computer toolchain offload
with the 'nk' client.
"""
import ipaddress
import json
import os
import shutil
import socket
import subprocess
import threading

HOST = "0.0.0.0"  # Standard loopback interface address (localhost)
PORT = 8056  # Port to listen on (non-privileged ports are > 1023)

top = ""
targets = {}
target_name = "cx16prog8"


def process_file(lines, name, size, output_dir):
    """
    Processes a file by reading further in the stream and
    then writing it out to the output_dir
    """
    global top
    first_line = True
    blank_line = False
    last_blank = False
    file_len = 0
    file_name = os.path.basename(os.path.normpath(name))

    with open(output_dir + os.sep + file_name, "wb") as fileh:
        for line in lines:
            blank_line = bool(line == b"")
            if last_blank and line == b">DONE":
                fileh.close()
                break

            # this part keeps from adding an
            # extra blank line at the start or end
            if not first_line:
                fileh.write(b"\n")
                file_len += 1
            else:
                first_line = False
            # write line to file.
            fileh.write(line)
            file_len += len(line)

            # save blank status of current line to last line status.
            last_blank = blank_line

    # could return whether the sizes matched.
    if size != file_len:
        print(f"WARN: file size mismatch: {size} vs {file_len}")
    return file_len


def process(data, ipa):
    """
    Process the data from the client
    """
    blank_line = False
    last_blank = False
    skip_file = False
    main_file = "unknown"
    file_name = "unknown"
    project_name = "unknown"
    global target_name
    file_count = 0
    file_size = 0
    files_received = 0

    # $PWD/output/7f000001_target_project
    output_prefix = os.getcwd() + os.sep + "output" + os.sep + ipa + "_"

    response = {"status": "unknown", "output": "", "error": "", "binary": ""}
    # default target
    target_name = "cx16prog8"
    target = targets.get(target_name)
    client_name = "unknown"
    project_name = "undefined"
    output_dir = "error"

    data_list = data.splitlines()
    for index, line in enumerate(data_list):
        blank_line = bool(line == b"")

        # look for end of file marker first thing
        if last_blank and line == b">DONE":
            skip_file = False
            continue

        # if we didn't find ">DONE" above and are skipping
        # over a file, continue to next line.
        if skip_file:
            last_blank = blank_line
            continue

        # not in the process of skipping over a file
        # which means we can look for keywords
        if line.startswith(b">CLIENT:"):
            client_name = line.decode("utf8").split(":")[1]
            print(f"Client name: {client_name}")
            # skip to next line
            continue

        if line.startswith(b">PROJECT:"):
            project_name = line.decode("utf8").split(":")[1]
            print(f"Project name: {project_name}")
            # skip to next line
            continue

        if line.startswith(b">TARGET:"):
            target_name = line.decode("utf8").split(":")[1]
            print(f"Target: {target_name}")
            target = targets.get(target_name)
            if target is None:
                print(f"ERROR: uknown target: {target_name}")
            # cleanup output_dir now that we know the target
            output_dir = output_prefix + client_name + "_" + target_name + "_" + project_name
            output_dir = os.path.normpath(output_dir)
            if os.path.exists(output_dir):
                try:
                    print(f"DEBUG: removing old tree: {output_dir}")
                    shutil.rmtree(output_dir)
                except Exception:
                    print(f"DEBUG: output_dir issue: {output_dir}")

            try:
                os.mkdir(output_dir)
            except Exception as error:
                print(f"DEBUG: mkdir(output_dir) issue: {output_dir} {error}")
            # skip to next line
            continue

        if line.startswith(b">FILES:"):
            file_count = int(line.decode("utf8").split(":")[1])
            print(f"File count: {file_count}")
            # skip to next line
            continue

        if line.startswith(b">MAIN:"):
            main_file = line.decode("utf8").split(":")[1]
            file_size = int(line.decode("utf8").split(":")[2])
            print(f"Main file name: {main_file}")
            print(f"Main file size: {file_size}")
            process_file(data_list[index + 1 :], main_file, file_size, output_dir)
            files_received += 1
            # signal we want to skip over the file
            skip_file = True
            # skip to next line
            continue

        if line.startswith(b">EXTRA:"):
            file_name = line.decode("utf8").split(":")[1]
            file_size = int(line.decode("utf8").split(":")[2])
            print(f"Extra file name: {file_name}")
            print(f"Extra file size: {file_size}")
            process_file(data_list[index + 1 :], file_name, file_size, output_dir)
            files_received += 1
            # signal we want to skip over the file we just saved above
            skip_file = True
            # skip to next line
            continue

        # client requests compilation
        if line == b">COMPILE":
            if files_received != file_count:
                print(f"WARNING: Missing files? {files_received} vs {file_count}")
            print("INFO: Toolchain (compile/assemble) stage requested.")
            tool_args = target.get("tool_args").replace("{{output}}", project_name)
            args = (target["toolchain"] + " " + tool_args).split()
            args.append(main_file)
            result = subprocess.run(
                args, capture_output=True, cwd=output_dir, text=True
            )
            if result.returncode == 0:
                print("Toolchain succeeded")
                response["status"] = "OK"
                response["output"] = result.stdout
                response["error"] = result.stderr
                response["binary"] = project_name
                response["output_dir"] = output_dir
            else:
                print(f"Toolchain reports an error. ({result.returncode})")
                print("==== stderr ====")
                print(result.stderr)
                print("==== stdout ====")
                print(result.stdout)
                response["status"] = "FAIL"
                response["output"] = result.stdout
                response["error"] = result.stderr
            # done with compile
            continue
        print(f"WARNING: Unprocessed lines:{line}")
    return response


def serve(connection, address):
    """
    Serve a single client request
    """
    with connection:
        print("Connection from:", address)
        ipa = ipaddress.ip_address(connection.getpeername()[0])
        newdata = b""
        # keep reading until we either see the compile request
        # or we stop reading any data.
        while True:
            readdata = connection.recv(65536)
            # print(f"DEBUG: readdata: {readdata}")
            newdata += readdata
            if b">COMPILE" in newdata:
                break
            if readdata == b"":
                print("DEBUG: blank data")
                break

        result = process(newdata, ipa.packed.hex())
        connection.sendall(b"")
        if result["status"] == "OK":
            output = result["output"].encode("utf8").replace(b"\x0a", b"\x0d")
            connection.sendall(b">OUTPUT\r")
            connection.sendall(output)
            connection.sendall(b"\r")
            connection.sendall(b"\r")
            connection.sendall(b">BINARY\r")
            filename = result["binary"]
            output_dir = result.get("output_dir")
            filedata = open(output_dir + os.sep + filename, "rb").read()
            connection.sendall(filedata)
        else:
            output = result["error"].encode("utf8").replace(b"\x0a", b"\x0d")
            connection.sendall(b">ERROR\r")
            connection.sendall(output)
            connection.sendall(b"\r")

        # flush socket?
        connection.sendall(b"")


def readjson(filename):
    """
    Read a JSON file in a standard way with error checking.
    :param filename:
    :return: dictionary of file contents
    """
    try:
        with open(filename, "r") as fileh:
            return json.load(fileh)
    except IOError as error:
        print(error)
        return None


def writejson(filename, data):
    """
    Write a JSON file in a standard way with error checking.
    :param filename:
    :param data: dictionary to write out as JSON
    :return: True or False status of write
    """
    try:
        with open(filename, "w") as fileh:
            json.dump(data, fileh, indent=4, sort_keys=True)
    except IOError as error:
        print(error)
        return False
    return True


# This only handles one connection and then exits.
# Once it is more stable it should handle multiple clients.
def main():
    """
    Creates a socket and waits for a connection.
    Currently processes a single connection and exits.
    """
    global targets
    global top
    top = os.getcwd()
    targets = readjson("targets.json")
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            s.bind((HOST, PORT))
            s.listen(5)
            print("Waiting for a client connection...")

            while True:
                conn, addr = s.accept()
                client_handler = threading.Thread(target=serve, args=(conn, addr))
                client_handler.start()
        #        except ConnectionResetError:
        #            print("Connection closed by remote host...")
        #            s.close()
        except KeyboardInterrupt:
            print("Control-C pressed, cleaning up...")
            s.close()
        finally:
            print("Exiting now...")

    print("Done.")


if __name__ == "__main__":
    main()
