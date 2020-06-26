Este es un fork del proyecto original [Epidemic Calculator](https://github.com/gabgoh/epcalc)
de Gabriel Goh. En su primera versión es simplemente una traducción al castellano de la interface web
para facilitar su uso en Argentina (ver modificaciones mas abajo). La idea es jugar con el modelo 
para enriquecer nuestros análisis de los datos de COVID-19.

Para que funcione simplemente hay que clonar el repo y luego hacer:

```bash
npm install --no-fund
```
ignorar los warnings y luego:
```bash
npm run dev
```
Luego en un browser ingresar el url: http://localhost:5000/

Puede ser necesario instalar *npm*, Para instalarlo segun tu distro usar 

- **Arch**: https://www.archlinux.org/packages/community/any/npm/
- **Ubuntu**
  ```bash
  $ sudo apt install npm
  ```

# Nuevos features:
Se añadieron nuevos parámetros para:
- Definir una función en el tiempo del ritmo repdroductivo, esto permite modelar las intervenciones realizadas,
tanto en su duración como en su magnitud. 
- Controlar el ritmo reproductivo a la salida del período de intervención.
- También debido a que la detección de nuevos casos es un procedimiento que puede tardar varios
días, se añadió un tiempo de retardo para modelar la demora del efecto que tiene la cuarentena
en el número de casos confirmados.
- Se cambio el sistema de slides por el de curvas poligonales para mayor claridad.
- Se añadió un boton de descarga para obtener un archivo csv con los resultados del modelo.
- Se añadió como scatter plot los casos confirmados y las muertes de COVID-19 en Argentina (datos acumulados), para permitir
visualizar con la applet como la variación de parámetros impacta en la predicción de los mismos.
- Los parámetros por defecto son obtenidos mediante un ajuste en los incrementos (ya que ajustar datos acumulados no es correcto en estadística), este se realiza mediante una exploración mediante cadenas de markov (aunque el likelihood de las mediciones es estimado asumiendo shot noise, lo cual puede no ser correcto).
- El ajuste de la curva de casos se realiza a partir del día 5, ya que como muchos
ya notaron a partir de ese momento empieza a evidenciarse el comportamiento exponencial.
Encontré que no solo debía ajustar el parámetro R0, si no que además era necesiario asumir
un número de casos expuestos mayor a los 9 casos infectados de ese día, lo cual es razonable,
ya que uno espera que antes de presentar síntomas o de ser detectado el caso, éste pueda exponer
a más personas. 

---

A continuacion el README orginal de Dr. Goh:


*Psst — looking for a shareable component template? Go here --> [sveltejs/component-template](https://github.com/sveltejs/component-template)*

---

# svelte app

This is a project template for [Svelte](https://svelte.dev) apps. It lives at https://github.com/sveltejs/template.

To create a new project based on this template using [degit](https://github.com/Rich-Harris/degit):

```bash
npx degit sveltejs/template svelte-app
cd svelte-app
```

*Note that you will need to have [Node.js](https://nodejs.org) installed.*


## Get started

Install the dependencies...

```bash
cd svelte-app
npm install
```

...then start [Rollup](https://rollupjs.org):

```bash
npm run dev
```

Navigate to [localhost:5000](http://localhost:5000). You should see your app running. Edit a component file in `src`, save it, and reload the page to see your changes.

By default, the server will only respond to requests from localhost. To allow connections from other computers, edit the `sirv` commands in package.json to include the option `--host 0.0.0.0`.


## Deploying to the web

### With [now](https://zeit.co/now)

Install `now` if you haven't already:

```bash
npm install -g now
```

Then, from within your project folder:

```bash
cd public
now
```

As an alternative, use the [Now desktop client](https://zeit.co/download) and simply drag the unzipped project folder to the taskbar icon.

### With [surge](https://surge.sh/)

Install `surge` if you haven't already:

```bash
npm install -g surge
```

Then, from within your project folder:

```bash
npm run build
surge public
```
