
# Random Forests medición alternativa de la importancia de los atributos

Trabajo Fin de Máster. \
Alumno [Francisco Saucedo](https://www.linkedin.com/in/franciscosaucedo/). \
[Máster Universitario en Ingeniería Informática](https://www.upo.es/postgrado/Master-Oficial-Ingenieria-Informatica/). \
[Universidad Pablo de Olavide](https://www.upo.es). \

## Introducción

Fork del [repositorio Weka oficial, versión 3.8](https://git.cms.waikato.ac.nz/weka/weka/-/tree/stable-3-8), para el Trabajo Fin de Máster. Se ha extendido para usar la medida MSU, propuesta en el artículo científico [A multivariate approach to the symmetrical uncertainty measure: Application to feature selection problem](https://www.sciencedirect.com/science/article/abs/pii/S0020025519303603), para la selección de atributos en la creación de árboles aleatorios del algoritmo [Random Forests](https://link.springer.com/content/pdf/10.1023/A:1010933404324.pdf).

## Requisito: registro de librerías para cálculo de la MSU

```
mvn install:install-file -Dfile=lib/nbp-jcommonutils-master.jar \
    -DgroupId=upo \
    -DartifactId=jcu \
    -Dversion=1.0.0 \
    -Dpackaging=jar \
    -DgeneratePom=true
    
mvn install:install-file -Dfile=lib/nbp-jmachinelearning-master.jar \
    -DgroupId=upo \
    -DartifactId=jml \
    -Dversion=1.0.0 \
    -Dpackaging=jar \
    -DgeneratePom=true
```

## Uso

### Compilación

```
mvn clean install -DskipTests=true
```

## Ejemplo de ejecución

```
java -cp dist/weka-stable-3.8.7-SNAPSHOT.jar:lib/* \
         weka.classifiers.trees.RandomForest \
         -P 100 -I 100 -num-slots 1 -K 0 -M 1.0 -V 0.001 -S 1 \
         -t ../wekadocs/data/weather.nominal.arff
```

## Referencias

* [A multivariate approach to the symmetrical uncertainty measure: Application to feature selection problem](https://www.sciencedirect.com/science/article/abs/pii/S0020025519303603).
* [Weka 3: Machine Learning Software in Java](https://www.cs.waikato.ac.nz/ml/weka/index.html).
* [Scripts auxiliares para el Trabajo Fin de Máster](https://github.com/fcosfc/scripts-tfm).