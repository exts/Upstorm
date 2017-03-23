# Upstorm

Used to update your copy of phpstorm with any version if it exists

## Installation

Shouldn't need any libraries to build, it uses crystals std to do everything. Just compile using `crystal build upstorm.cr` and you're good to go.

## Usage

To run you'll need to `sudo upstorm` assuming you added it to your `/usr/local/bin` in order to move the contents to /opt/phpstorm

For the user input when changing the folder there are a few commands available:

- `r` - to reset the folder
- `q` - to quit the application
- `y` - to confirm that's the correct path

When giving a version number there's a few commands:

- `q` - to quit
- leave it blank if a version is set to rerun

## Included tar.gz

I have a compiled version attached, should work. I'll test it on my laptop later where crystal isn't installed to see if it works as intended.

## Contributors

exts - creator, maintainer
