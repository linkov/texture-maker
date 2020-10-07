use std::os::raw::{c_char};
use std::ffi::{CString, CStr};
use std::os::raw::c_int;
use core_foundation::{
    base::TCFType,
    string::{CFString, CFStringRef},
};
use std::convert::TryInto;

use log::*;
use mpsc::Receiver;
use std::{
    sync::mpsc::{self, Sender},
    thread,
};

use texture_synthesis as ts;


//MARK: Incoming params
#[no_mangle]
pub extern fn begin_with_filepath(filepath: *const c_char, size: c_int ) -> *mut c_char {

   
    let c_str = unsafe { CStr::from_ptr(filepath) };
    let recipient = match c_str.to_str() {
        Err(_) => "there",
        Ok(string) => string,
    };
    begin_transform(recipient.to_string(),size);
    CString::new("Hell ".to_owned() + recipient).unwrap().into_raw()
}

#[no_mangle]
pub extern fn filepath_free(s: *mut c_char) {
    unsafe {
        if s.is_null() { return }
        CString::from_raw(s)
    };
}


//MARK: Callback
pub static mut CALLBACK_SENDER: Option<Sender<String>> = None;

#[no_mangle]
pub unsafe extern "C" fn register_callback(
    callback: unsafe extern "C" fn(CFStringRef),
) {
    register_callback_internal(Box::new(callback));

    // Let's send a message immediately, to test it


    
}
unsafe fn send_to_callback(string: String) {
    match &CALLBACK_SENDER {
        Some(s) => {
            s.send(string).expect("Couldn't send message to callback!");
        }
        None => {
            info!("No callback registered");
        }
    }
}
fn register_callback_internal(callback: Box<dyn MyCallback>) {
    // Make callback implement Send (marker for thread safe, basically) https://doc.rust-lang.org/std/marker/trait.Send.html
    let my_callback =
        unsafe { std::mem::transmute::<Box<dyn MyCallback>, Box<dyn MyCallback + Send>>(callback) };

    // Create channel
    let (tx, rx): (Sender<String>, Receiver<String>) = mpsc::channel();

    // Save the sender in a static variable, which will be used to push elements to the callback
    unsafe {
        CALLBACK_SENDER = Some(tx);
    }

    // Thread waits for elements pushed to SENDER and calls the callback
    thread::spawn(move || {
        for string in rx.iter() {
            let cf_string = to_cf_str(string);
            my_callback.call(cf_string)
        }
    });
}

fn to_cf_str(str: String) -> CFStringRef {
    let cf_string = CFString::new(&str);
    let cf_string_ref = cf_string.as_concrete_TypeRef();
    ::std::mem::forget(cf_string);
    cf_string_ref
}

pub trait MyCallback {
    fn call(&self, par: CFStringRef);
}

impl MyCallback for unsafe extern "C" fn(CFStringRef) {
    fn call(&self, par: CFStringRef) {
        unsafe {
            self(par);
        }
    }
}


//MARK: Transform
fn begin_transform(url_string: String, size: c_int) {

  
    let result = run_transform(url_string.to_string(), size);

    if result.is_ok() {
       unsafe {
        send_to_callback("Hello callback YES!".to_owned());
       } 
    }  else  {

        unsafe {

            send_to_callback("Hello callback NO!".to_owned());
        }
        
    }

}

fn run_transform(url_string: String, size: c_int ) -> Result<(), ts::Error> {

    let result: Result<u32, std::num::TryFromIntError> = size.try_into();

    //create a new session
    let texsynth = ts::Session::builder()
        //load a single example image
        .add_example(&url_string)
        .output_size(ts::Dims::square(result.unwrap()))
        .build()?;

    //generate an image
    let generated = texsynth.run(None);

    //save the image to the disk
    generated.save("01.jpg")

}

