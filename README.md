Este es un fork del proyecto original [Epidemic Calculator](https://github.com/gabgoh/epcalc)
de Gabriel Goh. En su primera versión es simplemente una traducción al castellano de la interface web
para facilitar su uso en Argentina. La idea es jugar con el modelo para enriquecer nuestros análisis de los datos de COVID-19.

Para que funcione simplemente hay que clonar el repo y luego hacer:

```bash
npm install --no-fund
```
ignorar los warnings y luego:
```bash
npm run dev
```
Luego en un browser ingresar el url: http://localhost:5000/

Puede ser necesario instalar npm, en el caso de archlinux tuve que instalar este [paquete](https://www.archlinux.org/packages/community/any/npm/)

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
