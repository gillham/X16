%option ignore_unused

os {
    ; cx16os functions.
    extsub $9d00 = getc() clobbers(X, Y) -> ubyte @ A
    extsub $9d03 = chrout(ubyte character @ A)
    extsub $9d06 = exec()
    extsub $9d09 = print_str()
    extsub $9db4 = get_console_info()
    extsub $9db7 = set_console_mode()
    extsub $9dba = set_stdin_read_mode()
    extsub $9d0c = get_process_info()
    extsub $9d0f = get_args()
    extsub $9d12 = get_process_name()
    extsub $9da5 = active_table_lookup()
    extsub $9d15 = parse_num()
    extsub $9d99 = bin_to_bcd16()
    extsub $9d18 = hex_num_to_string()

    extsub $9d1b = kill_process()
    extsub $9d1e = open_file()
    extsub $9d21 = close_file()
    extsub $9d24 = read_file()
    extsub $9d27 = write_file()
    extsub $9d2a = load_dir_listing_extmem()
    extsub $9d2d = get_pwd(uword buffer @R0, uword count @R1)
    extsub $9d30 = chdir()
    extsub $9d9c = move_fd()
    extsub $9da8 = copy_fd()
    extsub $9dbd = pipe()

    ; extmem routines
    extsub $9d33 = res_extmem_bank()
    extsub $9d42 = free_extmem_bank()
    extsub $9d4b = share_extmem_bank()

    extsub $9d57 = set_extmem_wbank()
    extsub $9d36 = set_extmem_rbank()
    extsub $9d39 = set_extmem_rptr()
    extsub $9d3c = set_extmem_wptr()

    extsub $9d3f = readf_byte_extmem_y()
    extsub $9d48 = writef_byte_extmem_y()

    extsub $9d45 = vread_byte_extmem_y()
    extsub $9d4e = vwrite_byte_extmem_y()

    extsub $9dae = pread_extmem_xy()
    extsub $9db1 = pwrite_extmem_xy()

    extsub $9d51 = memmove_extmem()
    extsub $9d54 = fill_extmem()

    ; More system routines

    extsub $9d5d = wait_process()
    extsub $9d60 = fgetc()
    extsub $9d63 = fputc()
    extsub $9d66 = unlink()
    extsub $9d69 = rename()
    extsub $9d6c = copy_file()
    extsub $9d6f = mkdir()
    extsub $9d72 = rmdir()

    extsub $9d9f = get_time()
    extsub $9dab = get_sys_info()

    extsub $9d75 = setup_chrout_hook()
    extsub $9d78 = release_chrout_hook()
    extsub $9d87 = send_byte_chrout_hook()
    
    extsub $9d93 = lock_vera_regs()
    extsub $9d96 = unlock_vera_regs()

    extsub $9d7b = setup_general_hook()
    extsub $9d7e = release_general_hook()
    extsub $9d81 = get_general_hook_info()
    extsub $9d84 = send_message_general_hook()
    extsub $9d90 = mark_last_hook_message_received()

    extsub $9d8a = set_own_priority()
    extsub $9d8d = surrender_process_time()
    extsub $9da2 = detach_self()
}
