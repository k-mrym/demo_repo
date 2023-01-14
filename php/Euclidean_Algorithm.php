<?
/**
 * $a と $b の最大公約数を求める.
 * 【ユークリッドの互除法】
 */
function fac($a, $b) {
    // $aが$bより小さかったら入れ替え
    if ($a < $b) {
        $arr = compact('a','b');
        $a = $arr['b'];
        $b = $arr['a'];
    }

    $r = $a % $b;
    if ($r === 0) {
        return $b;
    }
    // 再帰
    return fac($b , $r);
}