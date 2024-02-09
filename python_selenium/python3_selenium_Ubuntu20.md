
# Ubuntu20 python selenium chrome chromedriver

## headless でブラウザを自動操作

[Python + Selenium で Chrome の自動操作を一通り](https://qiita.com/memakura/items/20a02161fa7e18d8a693)

[Ubuntu + Python3 + Selenium + GoogleChrome でスクレイピング](https://www.mt-megami.com/article/ubuntu-python3-selenium-googlechrome-scraping)

[seleniumで使用するWebDriverの3種類の取得方法](https://qiita.com/ti104110/items/903437574875c7778093)

[【Python】Selenium：ブラウザ操作して静的・動的（Ajax、javascript）ページから情報を取得](https://office54.net/python/module/python-selenium-chrome)

```bash
$ python3 -V
Python 3.10.12

$ sudo apt update

$ sudo apt -y upgrade

$ sudo apt clean

$ sudo apt install -y python3-pip

$ pip3 install --upgrade pip
Installing collected packages: pip
  WARNING: The scripts pip, pip3, pip3.10 and pip3.11 are installed in '/home/ubuntu/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed pip-23.2.1

$ vim ~/.bashrc
***↓追記↓***
###################################################################
###################################################################
export PATH="$PATH:$HOME/.local/bin"
************
```

### seleniumをインストール

```bash
$ pip install selenium
```

### Chrome インストール

```bash
$ cd /tmp
$ wget https://dl.google.com/linux/linux_signing_key.pub
$ sudo apt-key add linux_signing_key.pub
$ echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
$ sudo apt-get update
$ sudo apt -f install -y
$ sudo apt-get install google-chrome-stable
$ google-chrome --version
```

### chromedriver インストール

```bash
$ sudo apt install chromium-chromedriver
$ chromedriver -v
```

### webdriver-manager インストール

```bash
$ python3 -m pip install webdriver-manager
```

### [PHP で exec 関数を使ってブラウザから呼び出した命令を実行できない時の対処法](https://blog.n-hassy.info/2021/05/php-exec-on-browser/)

### TEST

```bash
# ******************* TEST1 **********************************
# ************************************************************
# - coding: utf-8 --
from selenium import webdriver
from selenium.webdriver import ChromeOptions
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By

url = "https://example.com/"

# ヘッドレスモードでブラウザを起動
options = ChromeOptions()
options.add_argument('--headless')

# サービスを起動
serv = Service(ChromeDriverManager().install())

# ブラウザーを起動
driver = webdriver.Chrome(service=serv, options=options)

# urlにアクセス
driver.get(url)
element_h1 = driver.find_element(By.TAG_NAME, 'h1')
print(element_h1.text)

# ブラウザ停止
driver.quit();
# ************************************************************
# ************************************************************


# ******************* TEST2 **********************************
# ************************************************************
# googleの検索窓に「"pythoneについて"と入力してググる」自動化program
# -----------------------------------------------------------
# seleniumオブジェクトのimport
# 様々なブラウザを制御するためのクラスを提供(主にWebアプリケーションのテストやスクレイピングなどに使用するモジュール)
from selenium import webdriver
# find_element() メソッドを呼び出す際に要素を見つける方法を指定するために使用
from selenium.webdriver.common.by import By
# 要素が特定の条件を満たすまで待機するために使用
from selenium.webdriver.support.ui import WebDriverWait
# WebDriverWait と組み合わせて、要素が特定の条件を満たすまで待機するために使用
from selenium.webdriver.support import expected_conditions

# Serviceクラスは、ブラウザのドライバーを実行するためのサービスを管理するためのクラス
# 通常、直接使用することはありませんが、カスタム設定が必要な場合に便利
from selenium.webdriver.chrome.service import Service
# -----------------------------------------------------------
import time # すべてのページが表示されるまで待機
# ------------------------------------------------------

from selenium.webdriver import ChromeOptions
options = ChromeOptions()
# ヘッドレスモード設定
options.add_argument('--headless')


#この部分がdriverの取得方法によって変わります。
from webdriver_manager.chrome import ChromeDriverManager
serv = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=serv, options=options)


driver.get('https://google.com')
# ------------------------------------------------------
# 検索文字を入力するためのxpath
xpath = '//*[@id="APjFqb"]'
search = "python" #input(‘検索する内容：')　# <- “python"　# を削除すれば入力方式に変更できます。

# タイムアウトを10秒に設定
wait = WebDriverWait(driver, 10)

# 検索文字列を入力
input = driver.find_element(By.XPATH,xpath)#<-selenium3以降
input.send_keys(search + 'について')
input.submit()

# すべてのページが表示されるまで2秒待機
time.sleep(2)
#ターミナルへ表示
for elem_h3 in driver.find_elements(By.XPATH,'//a/h3'):
    elem_a = elem_h3.find_element(By.XPATH,'..')
    print(elem_h3.text)
    print(elem_a.get_attribute('href'))
    print('')
    print('-'*50)
#　このドライバを終了し、開かれていたすべての関連ウィンドウを閉じる
driver.quit();
# ************************************************************
# ************************************************************
```
