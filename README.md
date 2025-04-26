# tk-export

A tool to export user data from [Tavern-Keeper](https://www.tavern-keeper.com) before it shuts down.

## Prerequisites

### For macOS:
- Elixir 1.16 or later
- Mix (comes with Elixir)

### For Windows:
- Elixir 1.16 or later
- Mix (comes with Elixir)

## Installation

### macOS
1. Install Elixir using Homebrew:
   ```bash
   brew install elixir
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/cschp/tk-export.git
   cd tk-export
   ```

3. Build the executable:
   ```bash
   mix escript.build
   ```

4. Run the executable:
   ```bash
   ./tk_export
   ```

### Windows
1. Install Elixir using the Windows installer from [elixir-lang.org](https://elixir-lang.org/install.html#windows)

2. Clone this repository:
   ```bash
   git clone https://github.com/cschp/tk-export.git
   cd tk-export
   ```

3. Build the executable:
   ```bash
   mix escript.build
   ```

4. Run the executable:
   ```bash
   tk_export
   ```

## Usage

1. Run the executable
2. Enter your Tavern-Keeper User ID when prompted
3. Enter your Tavern-Keeper session cookie when prompted
4. Wait for the export to complete
5. Check the 'exported-data' directory for your exported files

## Finding Your User ID and Session Cookie

### User ID
- Log in to Tavern-Keeper
- Go to your profile
- The User ID is the number in the URL (e.g., `https://www.tavern-keeper.com/user/1234` where 1234 is your User ID)

### Session Cookie
1. Open your browser's developer tools (F12 or right-click and select "Inspect")
2. Go to the "Application" or "Storage" tab
3. Look for "Cookies" on the left sidebar
4. Find the "tavern-keeper" cookie
5. Copy the value of the cookie

## License

This project is licensed under the terms of the MIT license.
You are free to use it as you wish.