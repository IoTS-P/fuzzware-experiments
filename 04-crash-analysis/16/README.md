# P2IM PLC
In the method `process_FC15` from `Modbus`, the bounds check is performed with user controlled data.
This allows an attacker to overwrite data following `regs`.
```C
int8_t Modbus::process_FC15( uint16_t *regs, uint8_t u8size )
{
    uint8_t u8currentRegister, u8currentBit, u8frameByte, u8bitsno;
    uint8_t u8CopyBufferSize;
    uint16_t u16currentCoil, u16coil;
    boolean bTemp;

    // get the first and last coil from the message
    uint16_t u16StartCoil = word( au8Buffer[ ADD_HI ], au8Buffer[ ADD_LO ] );
    uint16_t u16Coilno = word( au8Buffer[ NB_HI ], au8Buffer[ NB_LO ] );


    // read each coil from the register map and put its value inside the outcoming message
    u8bitsno = 0;
    u8frameByte = 7;
    for (u16currentCoil = 0; u16currentCoil < u16Coilno; u16currentCoil++)
    {

        u16coil = u16StartCoil + u16currentCoil;
        u8currentRegister = (uint8_t) (u16coil / 16);
        u8currentBit = (uint8_t) (u16coil % 16);

        bTemp = bitRead(
                    au8Buffer[ u8frameByte ],
                    u8bitsno );

        bitWrite(
            regs[ u8currentRegister ],
            u8currentBit,
            bTemp );

        u8bitsno ++;

        if (u8bitsno > 7)
        {
            u8bitsno = 0;
            u8frameByte++;
        }
    }

    // send outcoming message
    // it's just a copy of the incomping frame until 6th byte
    u8BufferSize         = 6;
    u8CopyBufferSize = u8BufferSize +2;
    sendTxBuffer();
    return u8CopyBufferSize;
```

In the provided input the `port` field of the modbus struct is overwritten, resulting in a crash while loading the pointer.
For an attacker it would be possible to set the pointer to a location with controlled data and thus allows arbitrary control over the instruction pointer.
