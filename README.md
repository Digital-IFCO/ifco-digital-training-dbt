# DBT training

### Set up the development environment

#### Installing the python version

The first thing you will need to run the code is a python binary needed to run python code and all the related tools. For this the best way to manage Python is through **pyenv**. Find installation instructions in the link below

* From Mac / Linux devs 👉 **https://github.com/pyenv/pyenv?tab=readme-ov-file#installation**
* For Windows devs 👉 **https://github.com/pyenv-win/pyenv-win**

Once installed, then just install the version needed and specified in the `.python-version` file

    pyenv install

Verify that you have successfully installed the correct python version (`v3.11`):

    python --version

We use Poetry to manage code dependencies and virtual environments. So the first thing you should do is installing Poetry 👇

**_https://python-poetry.org/docs/#installation_**

Install the dependencies 👇

    poetry install

Enable the poetry shell by:

    poetry shell



