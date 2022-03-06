<?
/**
 * $a と $b の最大公約数を求める.
 * 【ユークリッドの互除法】
 * 前提条件：2つの数字のうち、大きい方が$aに入る
 */
function fac($a, $b) {
    if ($a < $b) {
        // $a > $b でないと成り立たない
        return false;
    }

    $r = $a % $b;
    if ($r === 0) {
        return $b;
    }
    // 再帰
    return fac($b , $r);
}