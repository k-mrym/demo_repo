<?
    /**
     * 入れ子配列の中のある値の配列1つを取得したい。
     * 例）取得対象
     *   - キー：name
     *   - 値 : XXXX2
     * 
     *   $search = 'XXXX2';
     *   $target = getNestArr($search);
     * 
     * @return array|null
     */
    function getNestArr($search)
    {
        $arr = [
            0 => [
                'name' => 'XXXX1',
                'age' => 'YY1',
            ],
            1 => [
                'name' => 'XXXX2',
                'age' => 'YY2',
            ],
            2 => [
                'name' => 'XXXX3',
                'age' => 'YY3',
            ],
        ];
        $key = array_search($search, array_column($arr, 'name'), true);
        // $key=falese の場合 $list[0] とみなされてしまう為 null を当てる。
        $target[] = $key ? $arr[$key] : null;
        return $target;
    }

    /**
     * 部分一致検索で、入れ子配列の中のある値の配列を複数取得したい。
     * 例）取得対象
     *   - キー：directory
     *   - 値 : /tmp/dir*
     * 
     *   $search = '/tmp/dir';
     *   $target = getNestArrAmbSeach($search);
     * 
     * @return array|null
     */
    function getNestArrAmbSeach($search)
    {
        $arr = [
            0 => [
                'name' => 'XXXX1',
                'directory' => '/var/www',
            ],
            1 => [
                'name' => 'XXXX2',
                'directory' => '/tmp/dir/file.txt',
            ],
            2 => [
                'name' => 'XXXX3',
                'directory' => '/tmp/dir/dir2/file.txt',
            ],
        ];

        $keys = preg_grep("{^$search}", array_column($arr, 'directory'));

        if (!$keys) {
            return null;
        }

        foreach ($keys as $k => $v) {
            $target[] = $arr[$k];
        }

        return $target;
    }
