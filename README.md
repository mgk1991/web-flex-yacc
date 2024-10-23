# Web Flex & YACC IDE

A lightweight web-based development environment for Flex and YACC/Bison, featuring isolated sessions and easy file transfer capabilities. This containerized solution allows multiple users to work with Flex and YACC/Bison through their web browsers without requiring any local installation.

## Features

- 🌐 Browser-based access to Flex and YACC/Bison tools.
- 🔒 Isolated sessions per browser tab.
- 📁 Easy file upload/download through browser.
- 🧹 Automatic cleanup of session files.
- 🚀 No client-side installation required.
- 🔧 Includes GCC for compilation.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/mgk1991/web-flex-yacc

# Enter the directory
cd web-flex-yacc

# Start the container
docker compose up -d
```

Then open your browser at `http://localhost:7681`

## Usage

Each browser tab creates an temporal isolated session with its own workspace. All files are automatically deleted when closing the tab.

### File Transfer
- To upload files to the terminal workspace: Type `rz` in the terminal and select your file through the browser window.
- To download files from workspace to your computer: Type `sz filename` in the terminal and check your downloads folder.

### Development Flow
1. Open a new browser tab for a fresh session.
2. Upload your Flex (.l) and Bison (.y) files using `rz` or create/edit them locally using nano.
3. Compile and test your code.
4. Download results using `sz filename`.
5. Close the tab when done - all files will be automatically cleaned up from the server.

## Distribution

This repository only contains configuration files needed to build the development environment described above:

- `Dockerfile` - Build instructions for the container image.
- `docker-compose.yml` - Container orchestration configuration.
- `README.md` - Documentation.
- `LICENSE` - GNU GPL v3.0 license and attributions.

No binaries are distributed. The build process will fetch all components from their official sources:

- ttyd from https://github.com/tsl0922/ttyd
- lrzsz from https://ohse.de/uwe/releases/
- Flex and Bison from Alpine Linux repositories.
- GCC and other tools from Alpine Linux repositories.

## Built With

- [ttyd](https://github.com/tsl0922/ttyd) - Share your terminal over the web.
- [lrzsz](https://ohse.de/uwe/software/lrzsz.html) - For file transfer capabilities.
- [Flex](https://github.com/westes/flex) - The Fast Lexical Analyzer.
- [Bison](https://www.gnu.org/software/bison/) - GNU Parser Generator.
- [GCC](https://gcc.gnu.org/) - GNU Compiler Collection.

## Security Considerations

This environment is designed for:
- Development and educational purposes.
- Trusted networks.
- Temporary sessions.

Please note:
- No authentication or security implemented.
- No persistent storage.
- No process isolation beyond session separation.

## Resources

- [Flex Manual](https://westes.github.io/flex/manual/)
- [Bison Manual](https://www.gnu.org/software/bison/manual/)
- [Flex & Bison Tutorial](https://aquamentus.com/flex_bison.html)

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.