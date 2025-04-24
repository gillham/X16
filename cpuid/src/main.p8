%zeropage basicsafe
%option no_sysinit
%import textio

main {
    const ubyte rtcaddr = $6f
    const ubyte seconds = $00
    const ubyte rtcctrl = $07
    const ubyte alm0sec = $0a
    const ubyte alm0dow = $0d

    const ubyte mfplevel   = %10000000
    const ubyte almpol     = %10000000
    const ubyte alm0act    = %00010000
    const ubyte alm0match  = %10001111
    const ubyte almintflag = %00001000

    const ubyte almctrlmask = %11111000
    const ubyte oscenable   = %10000000


    bool rtcerror = false
    bool nmi_fired = false
    uword old_nmi = $0000

    ubyte old_control
    ubyte old_alm0dow
    ubyte old_alm0sec

    sub start() {
        ubyte bcd_second
        ubyte current_second
        ubyte temp

        txt.lowercase()

        txt.print("Replacing NMI handler...")
        txt.nl()

        sys.set_irqd()
        ; save old handler
        old_nmi = cbm.NMINV 
        ; configure my handler
        cbm.NMINV = &main.nmi
        sys.clear_irqd()

        if rtcsave() {
            txt.print("start control: ")
            txt.print_ubbin(old_control, false)
            txt.nl()
            txt.print("start alm0sec: ")
            txt.print_ubbin(old_alm0sec, false)
            txt.nl()
            txt.print("start alm0dow: ")
            txt.print_ubbin(old_alm0dow, false)
            txt.nl()
        } else {
            txt.nl()
            txt.print("error reading rtc")
            txt.nl()
        }

        txt.print("Configuring alarm...")
        txt.nl()

        ; make sure oscillator is running
        void cx16.i2c_write_byte(rtcaddr, seconds, 1<<7)

        ; read current seconds
        bcd_second, void = cx16.i2c_read_byte(rtcaddr, seconds)
        ; mask off ST (oscillator start/stop bit)
        bcd_second &= ~oscenable
        current_second = bcd2dec(bcd_second)

        ; set alarm polarity for multi-function pin
        rtcerror = cx16.i2c_write_byte(rtcaddr, alm0dow, almpol)
        if rtcerror {
            txt.print("error setting alm0dow")
            txt.nl()
        }
        ; set alarm second to now + 2
        ;rtcerror = cx16.i2c_write_byte(rtcaddr, alm0sec, dec2bcd(current_second + 2))
        rtcerror = cx16.i2c_write_byte(rtcaddr, alm0sec, dec2bcd(current_second + 1))
        if rtcerror {
            txt.print("error setting alm0sec")
            txt.nl()
        }
        ; enable alarm 0
        ;rtcerror = cx16.i2c_write_byte(rtcaddr, rtcctrl, (old_control | alm0act) & ~mfplevel)
        rtcerror = cx16.i2c_write_byte(rtcaddr, rtcctrl, old_control | alm0act | mfplevel)
        ;rtcerror = cx16.i2c_write_byte(rtcaddr, rtcctrl, old_control | alm0act)
        if rtcerror {
            txt.print("error setting rtcctrl")
            txt.nl()
        }

        ; print current alarm config
        ; rtc data
        temp, rtcerror = cx16.i2c_read_byte(rtcaddr, rtcctrl)
        if rtcerror {
            txt.print("error reading rtcctrl")
            txt.nl()
        }

        txt.print("new control: ")
        txt.print_ubbin(temp, false)
        txt.nl()

        temp, rtcerror = cx16.i2c_read_byte(rtcaddr, alm0sec)
        if rtcerror {
            txt.print("error reading alm0sec")
            txt.nl()
        }

        txt.print("new alm0sec: ")
        txt.print_ubbin(temp, false)
        txt.nl()

        temp, rtcerror = cx16.i2c_read_byte(rtcaddr, alm0dow)
        if rtcerror {
            txt.print("error reading alm0dow")
            txt.nl()
        }

        txt.print("new alm0dow: ")
        txt.print_ubbin(temp, false)
        txt.nl()

        txt.print("Waiting for alarm to fire.")
        txt.nl()

        ; check if we got an alarm for a few seconds.
        repeat 10 {
            temp, rtcerror = cx16.i2c_read_byte(rtcaddr, alm0dow)
            txt.print("alm0dow: ")
            txt.print_ubbin(temp, false)
            txt.nl()
            ; if the alarm has fired, clear it and break.
            if (temp & almintflag) != 0 {
                rtcerror = cx16.i2c_write_byte(rtcaddr, alm0dow, temp & ~almintflag)
                txt.print("alarm fired!")
                txt.nl()
                break
            }
            sys.wait(20)
        }

        txt.nl()
        txt.print("Restoring NMI handler...")
        txt.nl()
        sys.set_irqd()
        cbm.NMINV = main.old_nmi
        sys.clear_irqd()

        void rtcrestore()

        ;void cx16.i2c_write_byte(rtcaddr, rtcctrl, old_control | mfplevel)
        if nmi_fired {
            txt.nl()
            txt.print("OtterX detected!")
            txt.nl()
        }
    }

    sub nmi() -> bool {
        txt.print("nmi")
        txt.nl()
        main.nmi_fired = true
        ;
        ; cleanup before returning.
        ; pull bank and 'a' from stack.
        ;
        %asm {{
            pla
            sta $01
            pla
            rti
        }}
    }

    sub bcd2dec(ubyte val) -> ubyte {
        ;return((val & 240) >> 4) * 10 + (val & 15)
        return val - 6 * (val >> 4)
    }
    sub dec2bcd(ubyte val) -> ubyte {
        ;return ((val / 10) << 4) + (val % 10)
        return val + 6 * (val / 10)
    }

    sub rtcrestore() -> bool {
        bool ok = true

        ; restore rtc data
        ; disable alarm 0 before restoring alarm 0 seconds (potentially to 0)
        rtcerror = cx16.i2c_write_byte(rtcaddr, rtcctrl, old_control)
        if rtcerror ok = false

        ; this is done after disable alarm 0 so we don't get an extra alarm
        rtcerror = cx16.i2c_write_byte(rtcaddr, alm0sec, old_alm0sec)
        if rtcerror ok = false

        ; restore day of week, potentially clearly any pending interrupt flag
        rtcerror = cx16.i2c_write_byte(rtcaddr, alm0dow, old_alm0dow)
        if rtcerror ok = false

        return ok
    }

    sub rtcsave() -> bool {
        bool ok = true

        ; backup rtc data
        old_control, rtcerror = cx16.i2c_read_byte(rtcaddr, rtcctrl)
        if rtcerror ok = false

        old_alm0sec, rtcerror = cx16.i2c_read_byte(rtcaddr, alm0sec)
        if rtcerror ok = false

        old_alm0dow, rtcerror = cx16.i2c_read_byte(rtcaddr, alm0dow)
        if rtcerror ok = false

        return ok
    }

}
