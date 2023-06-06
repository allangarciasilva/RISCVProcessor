MEMORY 
{
        RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 256K
}
SECTIONS
{
    PROVIDE( _stack_ptr = ORIGIN(RAM) + LENGTH(RAM));

    .text :
    {
        _text = .;
        *(.text*)
        *(.rodata*)
        _etext = .;
    }
    
    .data : 
    {
        _data = .;
        *(.got*)
        *(.data*)
        _edata = .;
    }
    
    .bss :
    {
        _bss = .;
        *(.bss*)
        *(COMMON)      
        _ebss = .;
    }
}
