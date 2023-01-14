<?
/**
 * ファイルを1行ずつ読み込み
 * ex.)
 * /var/www/html/test.txt
 * 1,4140,mail@test.net,テスト ナマエ
 * 1,4141,dummy@dummy.com,ダミー テスト
 */ 
$filePath = '/var/www/html/test.txt';

$handl = fopen($filepath, 'r');
$i=1;
while($line = fgets($handl)){
    echo( '【'.$i.'行目】'.$line);
    // 変数へ格納
    list($status, $customerId, $email, $name) = explode(',', $line, 4);
    ++$i;
}
