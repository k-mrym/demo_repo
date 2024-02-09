import sys
# @debug print(sys.path)
import glob

# seleniumオブジェクトのimport
# 様々なブラウザを制御するためのクラスを提供(主にWebアプリケーションのテストやスクレイピングなどに使用するモジュール)
from selenium import webdriver
# find_element() メソッドを呼び出す際に要素を見つける方法を指定するために使用
from selenium.webdriver.common.by import By
# 要素が特定の条件を満たすまで待機するために使用
from selenium.webdriver.support.ui import WebDriverWait
# WebDriverWait と組み合わせて、要素が特定の条件を満たすまで待機するために使用
from selenium.webdriver.support import expected_conditions
	# Selectモジュール https://www.selenium.dev/ja/documentation/webdriver/support_features/select_lists/
from selenium.webdriver.support.select import Select

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
from webdriver_manager.chrome import ChromeDriverManager
serv = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=serv, options=options)


###### config ######
appDir = '/var/www/html'
debugImgDir = appDir + '/log/{image_directory}'
url = "https://{basic_user}:{basic_password}@{domain}/{path}"
loginName = 'XXXX'
loginPass = 'XXXX'
idInputName = 'XXXX'
idInputPassword = 'XXXX'
xpathSubmitBtn = "//button[@type='submit']"
xpathCsvUpload = "//*[@*='/csvUses/upload/']"
xpathCsvUploadRegBtn = "//*[starts-with(@href, '/csvUses/uploadDecision')]"
xpathListReferConfBtn = "//*[starts-with(@href, '/csvUses/listReferenceConf')]"
xpathListReferDecBtn = "//*[starts-with(@href, '/csvUses/ListReferenceDecision')]"
xpathMailSetBtn = "//*[starts-with(@href, '/mails/setting')]"
submitBtn2 = "//button[contains(text(), '送信する')]"
# submitBtn2 = ".btn-danger"
idUpFile = 'file-upfile'
idMailTemplate = 'mailTemplate-id'
windowWidth = 1024
windowHeight = 768

argvs = sys.argv

fileUploadDir = None
type = None
mailTemp = None
timer = None
# argvs[0]は実行ファイル名
if len(argvs) >= 3:
  fileUploadDir = argvs[1]
  type = argvs[2]
  if len(argvs) >= 4:
    mailTemp = argvs[3]
    if len(argvs) >= 5:
      timer = int(argvs[4])
# print('fileUploadDir: ' + fileUploadDir)
# print('type: ' + type)
# print('mailTemp: ' + mailTemp)
# print('timer: ' + timer)

files = glob.glob(fileUploadDir + "/*")
# print('files: ' + ', '.join(files))
print('count files: ' + str(len(files)))
####################

###### handle ######
# ページの取得（ベーシック認証）
driver.get(url)
# ログイン
inputName = driver.find_element(By.ID, idInputName)
inputName.send_keys(loginName)
inputPassword = driver.find_element(By.ID, idInputPassword)
inputPassword.send_keys(loginPass)
eleLoginSubmit = driver.find_element(By.XPATH, xpathSubmitBtn)
eleLoginSubmit.click()
# @debug ログイン後のURLを表示
print('url: ' + driver.current_url)

for k, file in enumerate(files):
  print('k: ' + str(k))
  print('file: ' + file)
  ## 「送信用 CSV アップロード」へ遷移
  eleLinkCsvUpload = driver.find_element(By.XPATH, xpathCsvUpload)
  # click()できないからブラウザサイズ指定. 参考：https://qiita.com/76r6qo698/items/de9cb7f41e8f887e8d3e
  # @debug
  # driver.save_screenshot(debugImgDir + '/csvUploadPage1.png')
  driver.set_window_size(windowWidth, windowHeight)
  # @debug
  # driver.save_screenshot(debugImgDir + '/csvUploadPage2.png')
  eleLinkCsvUpload.click()
  # @debug
  # csvUploadPageTitle = driver.find_element(By.TAG_NAME, 'h1')
  # print(csvUploadPageTitle.text)

  eleUpfile = driver.find_element(By.ID, idUpFile)
  eleUpfile.send_keys(file)
  eleUpfileSubmit = driver.find_element(By.XPATH, xpathSubmitBtn)
  #「登録確認」押下
  eleUpfileSubmit.click()
  time.sleep(3) #29万件で約2.5sec
  ## 送信用 CSV アップロード
  eleRegCsvUpload = driver.find_element(By.XPATH, xpathCsvUploadRegBtn)
  # 「登録」押下
  eleRegCsvUpload.click()
  time.sleep(5) #29万件で約4.5sec

  match type:
    case '1':
      print("***** [req1]start *****")
      ## CSV 登録済み詳細
      eleListReferConf = driver.find_element(By.XPATH, xpathListReferConfBtn)
      # 「リスト参照の実行」押下
      eleListReferConf.click()
      time.sleep(2)
      ## リスト参照
      eleListReferDec = driver.find_element(By.XPATH, xpathListReferDecBtn)
      # 「リスト参照を実行」押下
      eleListReferDec.click()
      time.sleep(2)
      print("****** [req1]end ******")
    
    case '2':
      print("***** [req2]start *****")
      ## CSV 登録済み詳細
      eleListReferConf = driver.find_element(By.XPATH, xpathListReferConfBtn)
      # 「リスト参照の実行」押下
      eleListReferConf.click()
      time.sleep(2)
      ## リスト参照
      eleListReferAfterMailSet = driver.find_element(By.XPATH, xpathMailSetBtn)
      # 「リスト参照後メールを送信する」押下
      eleListReferAfterMailSet.click()
      time.sleep(2)
      ## 送信内容設定
      print('送信内容設定_送信テンプレート選択画面_url: ' + driver.current_url)
      eleSelectMailTemp = driver.find_element(By.ID, idMailTemplate)
      # 「送信テンプレート」を選択
      select = Select(eleSelectMailTemp)
      select.select_by_value(mailTemp)
      time.sleep(2)
      ## 送信内容設定（確認画面）
      eleSendConfSubmit = driver.find_element(By.XPATH, xpathSubmitBtn)
      # 「送信確認」押下
      eleSendConfSubmit.click()
      time.sleep(3)
      # @debug
      print('送信内容設定_メール送信前確認画面_url: ' + driver.current_url)
      # 「送信する」押下
      # @debug
      # driver.save_screenshot(debugImgDir + '/debug.png')
      eleSendSubmit = driver.find_element(By.XPATH, xpathSubmitBtn)
      eleSendSubmit.click()
      time.sleep(3)
      # @debug
      print('メール送信確認1_url: ' + driver.current_url)
      # driver.save_screenshot(debugImgDir + '/debug2.png')
      
      # タイマー 最後はsleepしない
      if k < len(files) - 1:
        time.sleep(timer * 60)
      print("****** [req2]end ******")
    
    case '3':
      print("***** [req3]start *****")
      ## CSV 登録済み詳細
      eleMailSend = driver.find_element(By.XPATH, xpathMailSetBtn)
      # 「メールを送信する」押下
      eleMailSend.click()
      time.sleep(3)
      ## 送信内容設定
      eleSelectMailTemp = driver.find_element(By.ID, idMailTemplate)
      # 「送信テンプレート」を選択
      select = Select(eleSelectMailTemp)
      select.select_by_value(mailTemp)
      time.sleep(2)
      ## 送信内容設定（確認画面）
      eleSendConfSubmit = driver.find_element(By.XPATH, xpathSubmitBtn)
      # 「送信確認」押下
      eleSendConfSubmit.click()
      time.sleep(3)
      # @debug
      print('送信内容設定_メール送信前確認画面_url: ' + driver.current_url)
      # 「送信する」押下
      # @debug
      # driver.save_screenshot(debugImgDir + '/debug.png')
      eleSendSubmit = driver.find_element(By.XPATH, xpathSubmitBtn)
      eleSendSubmit.click()
      time.sleep(3)
      # @debug
      print('メール送信確認1_url: ' + driver.current_url)
      # driver.save_screenshot(debugImgDir + '/debug2.png')
      
      # タイマー 最後はsleepしない
      if k < len(files) - 1:
        time.sleep(timer * 60)
      print("****** [req3]end ******")
    
    case _:
      print("***** !req none! ******")

####################
driver.quit()
