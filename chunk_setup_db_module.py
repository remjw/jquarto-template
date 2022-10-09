## ---- python-module-db ---
#mysql_host = "127.0.0.1"
#mysql_user = "root"
#mysql_pwd = "apple"
#mysql_port = 3306

import yaml
import graphviz
import os
import pandas as pd
#pip install mysql-connector-python
#pip install truth-table-generator
import mysql.connector as mc
from mysql.connector import errorcode
from sqlalchemy import create_engine, types
import pymysql

def load_conf_file(config_file):
  with open(config_file, "r") as f:
    config = yaml.safe_load(f)
    print(config)
    info_conf = config["info"]
    mysql_conf = config["mysql"]
  return info_conf, mysql_conf
 
info_conf, mysql_conf = load_conf_file("_variables.yml")
mysql_host = mysql_conf["host"]
mysql_port = mysql_conf["port"]
mysql_user = mysql_conf["user"]
mysql_pwd = mysql_conf["password"]


def connect_mysql(db_name):
    try:
        db = mc.connect(
            host = mysql_host,
            port = mysql_port,
            user = mysql_user,
            password = mysql_pwd,
            database = db_name
        )
    except mc.Error as e:
        print(f"something went wrong:{e}")    
        return None
    else:
        print(f"Successful connection to {db_name}")
        return db

def sqlalchemy_sqlite3(db_name):
    engine = create_engine(f"sqlite:///{db_name}")
    return engine

def sqlalchemy_mysql(db_name):
    try:
        db_uri = f'mysql+pymysql://{mysql_user}:{mysql_pwd}@127.0.0.1:{mysql_port}/{db_name}?charset=utf8mb4'
        engine = create_engine(db_uri)
        #engine = engine.connect()
    except pymysql.Error as err:
        print(f'Connect failed: {err}')
        return None
    else:
        print(f"Successful connection to MySQL {db_name}")
        return engine


