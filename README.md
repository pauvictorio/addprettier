# Add Prettier

This is a simple PowerShell script to configure [Prettier](https://prettier.io/) with [@ianvs/prettier-plugin-sort-imports](https://github.com/ianvs/prettier-plugin-sort-imports) for a React/Next.js project.

The script checks for the existence of a `package.json` file. If found, it will add the Prettier scripts inside `package.json`. Then, it will ask you if you want to install the two packages as devDependencies using pnpm. Otherwise, the script will exit immediately.

It also checks for the existence of a `.prettierrc.json` file. If not found, it will copy the `.prettierrc.json` file from this repository to the root of your project. Otherwise, it will skip this step so you can preserve your existing `.prettierrc.json` options.

## Why

~~I'm lazy~~ I want to be able to just run a single command to configure Prettier to my project.

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

4. You may now use the `prettier` and `prettier:fix` scripts to check and fix your code formatting.

## Notes

Modify the options inside `.prettierrc.json` to fit your needs. Check the Prettier [options](https://prettier.io/docs/en/options) you may use, as well as the @ianvs/prettier-plugin-sort-imports [NPM docs](https://www.npmjs.com/package/@ianvs/prettier-plugin-sort-imports) for more information.

The set of `importOrder` options inside `.prettierrc.json` is directly lifted from James Shopland's [blog](https://www.jamesshopland.com/blog/sort-imports-with-prettier), kindly check them out.
