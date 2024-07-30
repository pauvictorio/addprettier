# Add Prettier

This is a simple PowerShell script to configure [Prettier](https://prettier.io/) and [@ianvs/prettier-plugin-sort-imports](https://github.com/ianvs/prettier-plugin-sort-imports) for a project.

The script checks for the existence of a `package.json` file. If found, it will add the necessary scripts to the `package.json` file and install the two packages as devDependencies using pnpm. Otherwise, the script will exit immediately.

It also checks for the existence of a `.prettierrc.json` file. If not found, it will copy the `.prettierrc.json` file from the `addprettier` folder to the root of your project. Otherwise, it will skip this step so you can preserve your existing `.prettierrc.json` options.

## Why

I'm lazy.

## Requirements

- **PowerShell**: 5.1
- **pnpm**: 9.5 or higher

## Installation

1. Run `git clone https://github.com/pauvictorio/addprettier.git addprettier` in your terminal.

2. Edit your PowerShell `$PROFILE`

   ```PS
   code $PROFILE
   ```

3. Add the following line:

   ```PS
   Set-Alias -Name addprettier -Value "C:\path\to\addprettier\Add-Prettier.ps1"
   ```

4. You may now use the `addprettier` command to add Prettier to your project.

## Usage

1. Modify the `$prettierConfigPath` variable to point to the location of the `.prettierrc.json` file.

    ```PS
    $prettierConfigPath = "C:\path\to\addprettier\.prettierrc.json"
    ```

2. You may also modify the following scripts to fit your needs:

    ```PS
    $scriptsToAdd = @{
        "prettier" = "prettier --check '**/**/*.{js,jsx,ts,tsx,css,json}'"
        "prettier:fix" = "prettier --write '**/**/*.{js,jsx,ts,tsx,css,json}'"
    }
    ```

3. Run the script in the root of your project.

    ```PS
    addprettier
    ```

4. You may now use the `prettier` and `prettier:fix` scripts to check and fix your code.

## Notes

Modify the options inside the `.prettierrc.json` file to fit your needs. Check the Prettier [docs](https://prettier.io/docs/en/options) and [@ianvs/prettier-plugin-sort-imports](https://www.npmjs.com/package/@ianvs/prettier-plugin-sort-imports) npm documentation for more information.

The set of `importOrder` options in this script is directly lifted from James Shopland's [blog](https://www.jamesshopland.com/blog/sort-imports-with-prettier), kindly check them out. Modify the options as needed.
