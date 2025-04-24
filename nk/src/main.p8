; Prog8 options
%encoding iso
%zeropage basicsafe
%option no_sysinit

; Prog8 libraries
%import conv
%import strings
%import textio

; local modules
%import libnet
%import socket

main {
    const uword bufsize = 8 * 256
    uword cfgbuf = memory("cfg", bufsize, 256)
    str cfgfile = "file.nk"
    str line = " " * 50
    uword bufptr

    ; file buffer
    const uword filebufsize = 20000
    uword filebuf = memory("file", filebufsize, 256)
    uword filesize

    ; receive buffer
    const uword recvbufsize = 10000
    uword recvbuf = memory("recv", recvbufsize, 256)
    uword recvbufptr
    uword recvsize

    ; extra files
    const uword extrabufsize = 170
    uword extrabuf = memory("extra", extrabufsize, 256)
;    uword extrabufptr
    uword extracount
;    uword[] extras = [$0000] * 10   ; array of ">EXTRA:filename" lines

    ; parsed parameters (used to connect)
    str host    = " " * 80          ; IP address or FQDN only (what size for IPv6?)
    uword port  = 8056              ; default port

    ; project / binary name
    str binary = " " * 17           ; 16 char max filename

    ; parameters send through to server
    str project = " " * 30          ; ">PROJECT:filename" (16 char max filename)
    str files   = " " * 10          ; ">FILES:NN"
    ubyte filecount                 ; the number of files above
    str source  = " " * 30          ; ">MAIN:filename" (16 char max filename)
    str target  = " " * 30          ; ">TARGET:cx16prog8"
    str sourcefile  = " " * 17      ; filename from above
    str done    = ">DONE"       ; message when file transfer is done
    str compile = ">COMPILE"     ; message sent to request compilation

    sub start() {
        ubyte charcount
;        ubyte index
        bool found
        txt.iso()
        txt.lowercase()

        txt.print("Network Kompile")
        txt.nl()

        ; needs better error checking
        uword count = read_file(cfgfile, cfgbuf, bufsize)
        if count > 0 {
            ; null terminate after the last byte of the file
            cfgbuf[count] = 0
            ; txt.print("#" * 20)
            ; txt.nl()
            ; txt.print(cfgbuf)
            ; txt.print("#" * 20)
            ; txt.nl()
        } else {
            txt.nl()
            txt.print("No bytes read?")
            txt.nl()
            sys.exit(1)
        }

        if not net.load() {
            txt.print("Network library load failed.")
            txt.nl()
            txt.print("Try: LOAD\"NET.BIN\" manually.")
            txt.nl()
            sys.exit(1)
        }

        ; debug
        txt.print("Parsing config file...")
        txt.nl()
        ; read the first line
        charcount = read_line()
        while charcount !=0 {
            ;look for hostname:port
            ; txt.nl()
            ; txt.print("line: ")
            ; txt.print(line)
            ; txt.nl()
            if strings.ncompare(">HOST:", line, 6) == 0 {
                parse_host()
            }
            if strings.ncompare(">PROJECT:", line, 9) == 0 {
                ; copy filename to use later to save the binary.
                void strings.copy(&line+9, binary)
                void strings.copy(&line, project)
                ; copy & convert entire line
                ; ascii_copy(&line, project, strings.length(&line))
            }
            if strings.ncompare(">TARGET:", line, 8) == 0 {
                void strings.copy(&line, target)
            }
            if strings.ncompare(">FILES:", line, 7) == 0 {
                void strings.copy(&line, files)
                ; copy & convert entire line
                ; ascii_copy(&line, files, strings.length(&line))
                ; also save as a ubyte in case we need it
                filecount = conv.str2ubyte(&line + 7)
                ; txt.nl()
                ; txt.print("files: ")
                ; txt.print(files)
                ; txt.nl()
                ; txt.print("filecount: ")
                ; txt.print_ub(filecount)
                ; txt.nl()
            }
            if strings.ncompare(">MAIN:", line, 6) == 0 {
                void strings.copy(&line, source)
                ; copy & convert entire line
                ; ascii_copy(&line, source, strings.length(&line))
                ; copy just filename
                void strings.copy(&line+6, sourcefile)
            }
            if strings.ncompare(">EXTRA:", line, 7) == 0 {
                void strings.copy(&line+7, extrabuf + (extracount * 17))
                extracount++
            }

            ; repeat {
            ;     charcount = read_line()
            ;     if charcount < 1 break
            ;     void socket.send_string(0, line)
            ; }
            
            ; get the next line (TODO: make sure this returns zero at the end)
            charcount = read_line()
        }

        ; txt.print("########## parsed config ##########")
        ; txt.nl()
        ; txt.print("host: ")
        ; txt.print(host)
        ; txt.nl()
        ; txt.print("port: ")
        ; txt.print_uw(port)
        ; txt.nl()
        ; txt.print(project)
        ; txt.nl()
        ; txt.print(files)
        ; txt.nl()
        ; txt.print(source)
        ; txt.nl()

        ; now do the actual connection
        ; move this to a sub routine
        socket.gethostbyname(host, strings.length(host)) 
        ;socket.gethostbyname("spren.roadsign.com", 18) 
        socket.open(0, port)
        if not socket.poll_open(0) {
            txt.nl()
            txt.print("failed to open socket")
            txt.nl()
            socket.close(0)
            sys.exit(1)
        }
        
        ; read main source file first
        filesize = read_file(sourcefile, filebuf, filebufsize)
        ; null terminate file contents
        filebuf[filesize] = 0
        ; append :filesize to this line
        fixup_file(source, filesize)

        ; debug
        ; txt.nl()
        ; txt.print("filebuf: ")
        ; txt.print(filebuf)
        ; txt.print(filebuf + 256)
        ; txt.nl()
        ; txt.print("filesize: ")
        ; txt.print_uw(filesize)
        ; txt.nl()

        ; project line (with compiled binary name)
        void socket.send_string(0, project)
        void socket.send_byte(0, $0a)

        ; target line (with platform/toolchain)
        void socket.send_string(0, target)
        void socket.send_byte(0, $0a)

        ; file count
        void socket.send_string(0, files)
        void socket.send_byte(0, $0a)

        ; main source file
        void socket.send_string(0, source)
        void socket.send_byte(0, $0a)
        ; void socket.send(0, filebuf, filesize)
        txt.print("sent bytes: ")
        txt.print_uw(socket.send_chunks(0, filebuf, filesize))
        txt.nl()
        void socket.send_byte(0, $0a)

        ; send a blank line prior to ">DONE"
        void socket.send_byte(0, $0a)

        ; ">DONE" marker for file
        void socket.send_string(0, done)
        void socket.send_byte(0, $0a)

        ; send any EXTRA files
        ubyte i = 0
        repeat extracount {
            ; read main source file first
            txt.nl()
            txt.print("EXTRA file: ")
            txt.print(extrabuf)
            txt.nl()
            filesize = read_file(extrabuf + (i * 17), filebuf, filebufsize)

            ; null terminate file contents
            filebuf[filesize] = 0

            ; send ">EXTRA:"
            void socket.send_string(0, ">EXTRA:")
            ; send filename
            void socket.send_string(0, extrabuf + (i * 17))
            ; send ':'
            void socket.send_byte(0, ':')
            ; send filesize
            void socket.send_string(0, conv.str_uw(filesize))
            void socket.send_byte(0, $0a)
            
            ; void socket.send(0, filebuf, filesize)
            txt.print("sent bytes: ")
            txt.print_uw(socket.send_chunks(0, filebuf, filesize))
            txt.nl()
            void socket.send_byte(0, $0a)

            ; send a blank line prior to ">DONE"
            void socket.send_byte(0, $0a)

            ; ">DONE" marker for file
            void socket.send_string(0, done)
            void socket.send_byte(0, $0a)
            i++
        }
        ; ">COMPILE" command
        void socket.send_string(0, compile)
        void socket.send_byte(0, $0a)

        txt.print("File sent, waiting (2 seconds) for compile...")
        txt.nl()

        ; delay 2 seconds
        sys.wait(120)

        ; read responses
        getdata()

        ; txt.nl()
        ; txt.print("recvsize: ")
        ; txt.print_uw(recvsize)
        ; txt.nl()

        charcount = recv_line()
        while charcount !=0 {
            if strings.ncompare(iso:">ERROR", line, 6) == 0 {
                txt.print("Compile error")
                txt.nl()
                ; goto the next line right away
                ; so we don't print ">ERROR" keyword
                charcount = recv_line()
                continue
            }
            if strings.ncompare(iso:">OUTPUT", line, 7) == 0 {
                txt.print("Compiler output")
                txt.nl()
                ; goto the next line right away
                ; so we don't print ">OUTPUT" keyword
                charcount = recv_line()
                continue
            }
            if strings.ncompare(iso:">BINARY", line, 7) == 0 {
                txt.print("Binary received...")
                txt.nl()
                ; txt.print("recvbufptr: ")
                ; txt.print_uw(recvbufptr)
                ; txt.nl()
                ; txt.print_uw(recvsize - recvbufptr)
                ; txt.nl()
                ; txt.print("saving to: ")
                ; txt.print(binary)
                ; txt.nl()
                if diskio.exists(binary) {
                    txt.print("deleting: ")
                    txt.print(binary)
                    txt.nl()
                    diskio.delete(binary)
                }
                void file_write(binary, recvbuf + recvbufptr, recvsize - recvbufptr)
                socket.close(0)
                sys.exit(0)
            }
            ; output lines from '>OUTPUT' or '>ERROR' etc
            txt.print(line)
            txt.nl()
            charcount = recv_line()
        }
        ; txt.print("recvbuf:")
        ; txt.nl()
        ; txt.print(recvbuf)
        txt.nl()

        socket.close(0)
    }

    ; copy a string from one to another converting to ascii
    sub ascii_copy(uword src, uword dest, ubyte length) {
        ubyte i = 0
        repeat length {
            dest[i] = pet2ascii(src[i])
            i++
        }
        ; null terminate string
        dest[i] = 0
    }

    ; append :filesize to string
    sub fixup_file(uword pointer, uword fsize) {
        ubyte strlen = strings.length(pointer)
        uword sizeptr = conv.str_uw(fsize)
        ubyte sizelen = strings.length(sizeptr)

        ; txt.nl()
        ; txt.print("debug: pointer: ")
        ; txt.print(pointer)
        ; txt.nl()
        ; txt.print_uw(strlen)
        ; txt.nl()
        ; txt.print("debug: fsize: ")
        ; txt.print_uw(fsize)
        ; txt.nl()
        ; txt.print("debug: sizeptr:")
        ; txt.print(sizeptr)
        ; txt.nl()
        ; txt.print(conv.str_uw(fsize))
        ; txt.nl()
        ; txt.print_ub(sizelen)
        ; txt.nl()

        ; add ":" to end of string
        pointer[strlen] = ':'
        ; txt.nl()
        ; txt.print("debug: after colon: ")
        ; txt.print(pointer)
        ; txt.nl()
        ; copy number string
        void strings.copy(sizeptr, pointer + strlen + 1)
        ; txt.nl()
        ; txt.print("debug: after strings.copy: ")
        ; txt.print(pointer)
        ; txt.nl()
        ; null terminate
        pointer[strlen + sizelen + 1] = 0

        ; txt.nl()
        ; txt.print("debug: fixed up file string: ")
        ; txt.nl()
        ; txt.print(pointer)
        ; txt.nl()

    }

    ; parse ">HOST:" lines
    sub parse_host() {
        ubyte index
        bool found

        ; ip or fqdn starts after ">HOST:" at index 6
        ; txt.print("fOUND host here:")
        ;txt.nl()
        ; txt.print(&line + 6)
        ; txt.nl()
        index, found = strings.find(&line + 6, ':')
        if found {
            ; txt.print("fOUND ':' at: ")
            ; txt.print_ub(index)
            ; txt.nl()
            line[6+index] = 0
            ; txt.print("about to copy: ")
            ; txt.print(&line+6)
            ; txt.nl()
            ; txt.print("index: ")
            ; txt.print_ub(index)
            txt.nl()
            ascii_copy(&line+6, host, index)
            txt.print("host: ")
            txt.print(host)
            txt.nl()
            port = conv.str2uword(&line + 7 + index)
            txt.print("port: ")
            txt.print_uw(port)
            txt.nl()
        }

    }


    ; reads user provided file into ptextbuf
    ; returns the number of bytes read.
    ; returns zero if f_open or f_read_all fails.
    sub read_file(uword filename, uword buffer, uword readsize) -> uword {
        uword count = 0
        txt.nl()
        txt.print("reading: ")
        txt.print(filename)
        if diskio.f_open(filename) {
            ; need to add error checking here
            count = diskio.f_read_all(buffer)
            ;count = diskio.f_read(buffer, readsize)
            txt.print(" (")
            txt.print_uw(count)
            txt.print(" bytes)")
            txt.nl()
        } else {
            txt.nl()
            txt.print("\nERROR: failed to open file.\n")
            txt.nl()
        }
        diskio.f_close()
        return count
    }

    ; write buffer to output filename.
    ; XXX: needs better handling of errors.
    sub file_write(uword filename, uword buffer, uword size) -> uword {
        ;uword count = 0
        txt.nl()
        txt.print("Writing: ")
        txt.print(filename)
        txt.nl()
        txt.print("Expecting ")
        txt.print_uw(size)
        txt.print(" bytes")
        txt.nl()
        if diskio.f_open_w(filename) {
            ; check status() here first...
            if diskio.f_write(buffer, size) {
                diskio.f_close_w()
                txt.print("Done (")
                txt.print_uw(size)
                txt.print(" bytes)")
                txt.nl()
            } else {
                ; should check status() here also.
                txt.print("\nwrite error\n")
            }
        } else {
            txt.print("\nERROR: failed to open file.\n")
        }
        ; file is left in an inconsistent state and 
        ; zero length if we don't close it properly
        diskio.f_close_w()
        return 0
    }



    ; read the next line into the temp buffer
    ; returns size of the line
    ; cfgbuf has the file contents
    ; line holds the line
    ; bufptr points to the next line
    sub read_line() -> ubyte {
        ubyte i = 0
        while cfgbuf[bufptr + i] != 0 {
            line[i] = cfgbuf[bufptr + i]
            if cfgbuf[bufptr + i] == $0d {
                line[i] = 0
                bufptr = bufptr + i + 1
                ; 'i' doesn't include the linefeed
                return i
            }
            i++
        }
    }

    ; read the next line into the temp buffer
    ; returns size of the line
    ; recvbuf has the server response
    ; line holds the line temporarily
    ; recvbufptr points to the next line
    sub recv_line() -> ubyte {
        ubyte i = 0
        while recvbufptr + i < recvsize {
            line[i] = recvbuf[recvbufptr + i]
            if recvbuf[recvbufptr + i] == $0d {
                line[i] = 0
                recvbufptr = recvbufptr + i + 1
                ; add 1 for the linefeed (for bare lines)
                return i + 1
            }
            i++
        }
    }

    ; convert ascii byte to petscii byte
    sub ascii2pet(ubyte char) -> ubyte {
        if char > 64 and char < 91 {
            char += 128
            return char
        } 
        if char > 92 and char < 123 {
            char -= 32
            return char
        }
        if char > 192 and char < 219 {
            char -= 128
            return char
        }
        when char {
            '_' -> return $a4
            '~' -> return 255
            $0a -> return $0d
        }
        return char
    }

    ; convert petscii byte to ascii byte
    sub pet2ascii(ubyte char) -> ubyte {
        if (128 + 64) < char and char < (128 + 91) {
            char -= 128
            return char
        } 
        if (96 -32) < char and char < (123 - 32) {
            char += 32
            return char
        }
        if (192 - 128) < char and char < (219 - 128) {
            char += 128
            return char
        }
        when char {
            $a4 -> return '_'
            $ff -> return '~'
            $0d -> return $0a
        }
        return char
    }

    sub getdata() {
        ; poll data loop (until server disconnects)
        repeat {
            sys.set_irqd()
            net.net_poll()
            sys.clear_irqd()

            ; check connected state first as
            ; socket status won't be valid
            ; after socket.recv()
            if net.poll.socket[0] & net.SOCK_STAT_HAS_DATA == 0 {
                ; no data & disconnected means we are done here..
                if (net.poll.socket[0] & net.SOCK_STAT_CONNECTED) == 0 {
                    break
                }
            } else {
                recvsize += socket.recv(0, 255, recvbuf + recvsize)
            }
        }
    }

}
