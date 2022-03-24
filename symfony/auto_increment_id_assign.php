<?
/**
 * オートインクリメントの ID を指定して登録
 */
function insertEntity(\Doctrine\ORM\EntityManager $em, $entity, $id = null, $columnName = 'id')
{
    $className = get_class($entity);
    if ($id) {
        $idRef = new \ReflectionProperty($className, $columnName);
        $idRef->setAccessible(true);
        $idRef->setValue($entity, $id);

        $metadata = $em->getClassMetadata($className);
        /** @var \Doctrine\ORM\Mapping\ClassMetadataInfo $metadata */
        $generator = $metadata->idGenerator;
        $generatorType = $metadata->generatorType;

        $metadata->setIdGenerator(new \Doctrine\ORM\Id\AssignedGenerator());
        $metadata->setIdGeneratorType(\Doctrine\ORM\Mapping\ClassMetadata::GENERATOR_TYPE_NONE);

        $unitOfWork = $em->getUnitOfWork();
        $persistersRef = new \ReflectionProperty($unitOfWork, "persisters");
        $persistersRef->setAccessible(true);
        $persisters = $persistersRef->getValue($unitOfWork);
        unset($persisters[$className]);
        $persistersRef->setValue($unitOfWork, $persisters);

        $em->persist($entity);
        $em->flush();

        $idRef->setAccessible(false);
        $metadata->setIdGenerator($generator);
        $metadata->setIdGeneratorType($generatorType);

        $persisters = $persistersRef->getValue($unitOfWork);
        unset($persisters[$className]);
        $persistersRef->setValue($unitOfWork, $persisters);
        $persistersRef->setAccessible(false);
    } else {
        $em->persist($entity);
        $em->flush();
    }
}