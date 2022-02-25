#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[no_mangle]
#[main]
pub extern "C" fn _start() -> ! { unsafe {
    const VIDEO: *mut char = 0xb8000 as *mut char;
    *VIDEO = 'X';
    loop {}
} }