#### Installing the project dependencies

We use Poetry to manage code dependencies and virtual environments. So the first thing you should do is installing Poetry. 
Be sure to execute the following command using the python environment installed by pyenv. To do this, close the terminal 
and open it again and run `python --version` to see that you are using python version 3.11.10  👇
    
    pip install poetry

Install the dependencies in the root path of this Project. For that, please, clone the Github project 👇

    git clone https://github.com/Digital-IFCO/ifco-digital-training-dbt.git

    cd ifco-digital-training-dbt
    
    poetry install

To make sure you are in the virtual environment you have just installed, run the following command

    poetry shell