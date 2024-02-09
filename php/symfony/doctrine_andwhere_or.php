<?

/**
 * LEFT JOIN aaa AS a ON b.aaa_id = a.id WHERE a.ccc IN(x, y, z) OR a.ddd IS NULL
 *  ※leftjoin 対象(xo)は @ManyToOne で定義済み
 */

    $Data = ['x','y','z'];
    /** patern1 **/ 
    $qb
        ->addselect('a')
        ->leftJoin('aaa', 'a')
        ->andWhere('a.ccc IN (:Data) OR a.ddd IS NULL')
        ->setParameter('Data', $Data)
    ;

    /** patern2 **/ 
    $qb
        ->addselect('a')
        ->leftJoin('aaa', 'a')
        ->andWhere($qb->expr()->orX(
            $qb->expr()->in('a.ccc', ':Data'),
            $qb->expr()->isNull('a.ddd')
        ))->setParameter('Data', $Data)
    ;



/**
 * WHERE a = 1 AND (b = 1 Or b = 2) AND (c = 1 OR c = 2)
 */

    /** patern1 **/ 
    $qb
        ->where("a = 1")
        ->andWhere("b = 1 OR b = 2")
        ->andWhere("c = 2 OR c = 2")
    ;
    
    /** patern2 **/
    $qb
        ->where('o.foo = 1')
        ->andWhere($qb->expr()->orX(
            $qb->expr()->eq('o.bar', 1),
            $qb->expr()->eq('o.bar', 2)
        ))
    ;


