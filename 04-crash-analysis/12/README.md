# P2IM Gateway
In the method `setPinState` of `FirmataClass`, the range for the `pin` argument is not checked.
This can lead to an out of bounds write in the data section.
In the given input one of the elements in `uart_handlers` is overwirtten.
Later this value is passed to the function `HAL_UART_GetState`, resulting in a crash.

1. funcion call chain:

`HardwareSerial::read => firmata::FirmataClass::processInput => firmata::FirmataParser::parse => staticPinModeCallback => setPinModeCallback => setPinstate`

2. in `loop` function's `processInput`, Firmata will read and process a byte in `parse`, which comes from previous UART input.
   
```diff
void firmata::FirmataClass::processInput(FirmataClass *this) {
+  iVar1 = HardwareSerial::read();
  if (iVar1 != -1) {
+    FirmataParser::parse(&this->parser,(uint8_t)iVar1);
```

```diff
ssize_t __thiscall HardwareSerial::read(HardwareSerial *this,int __fd,void *__buf,size_t __nbytes)
{
  byte bVar1;
  ushort uVar2;
  uchar c;
  
  uVar2 = (this->_serial).rx_tail;
  if ((uint)(this->_serial).rx_head != (uint)uVar2) {
+    bVar1 = (this->_serial).rx_buff[uVar2];
    (this->_serial).rx_tail = uVar2 + 1 & 0x3f;
    return (uint)bVar1;
  }
  return -1;
}
```

```diff
Basic Block: addr= 0x0000000008008b7c (lr=0x8002ee5)
         >>> Read: addr= 0x000000002000082c size=4 data=0x2000070d (pc 0x08008b7c)
+        >>> Read: addr= 0x000000002000070f size=1 data=0x00000021 (pc 0x08008b80)
         >>> Write: addr= 0x0000000020000832 size=2 data=0x00000003 (pc 0x08008b88)
```

3. The wrong UART value can be process in setPinState and provide as a index, which could cause buffer overflow 

```diff
void firmata::FirmataClass::setPinState(FirmataClass *this,byte pin,int state) {
+  this->pinState[pin] = state;
   return;
}
```

fuzzware log 
```diff
Basic Block: addr= 0x0000000008002fc6 (lr=0x8000737)
+        >>> Write: addr= 0x00000000200006c0 size=4 data=0x00000000 (pc 0x08002fc8)
```
