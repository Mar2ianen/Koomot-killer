use gpx::read;
use std::fs::File;
use std::io::BufReader;
use std::path::Path;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum GpxError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("GPX error: {0}")]
    Gpx(#[from] gpx::errors::GpxError),
}

pub fn load_gpx<P: AsRef<Path>>(path: P) -> Result<gpx::Gpx, GpxError> {
    let file = File::open(path)?;
    let reader = BufReader::new(file);
    let gpx = read(reader)?;
    Ok(gpx)
}
