
# Random Forests medición alternativa de la importancia de los atributos

Trabajo Fin de Máster. \
Alumno [Francisco Saucedo](https://www.linkedin.com/in/franciscosaucedo/). \
[Máster Universitario en Ingeniería Informática](https://www.upo.es/postgrado/Master-Oficial-Ingenieria-Informatica/). \
[Universidad Pablo de Olavide](https://www.upo.es).

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

### Utilidad para comparativas 

Permite comparar versiones estándar de Random Forest y Random Tree con las versiones de estudio creadas en el TFM, que utilizan MSU como medida de selección de atributos en la construcción de árboles de decisión.
La utilidad crea como salida un fichero CSV que contiene las distintas métricas, sus valores para los distintos algoritmos y la comparación de éstos.
Acciones:

* Obtener ayuda
```
cli/msu.sh
```

* Comparativa sobre un conjunto ejemplo de Weka

```
cli/msu.sh weather.nominal
```

## Referencias

* [A multivariate approach to the symmetrical uncertainty measure: Application to feature selection problem](https://www.sciencedirect.com/science/article/abs/pii/S0020025519303603).
* [Weka 3: Machine Learning Software in Java](https://www.cs.waikato.ac.nz/ml/weka/index.html).