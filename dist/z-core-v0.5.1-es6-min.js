(function(b){function a(b,d){if({}.hasOwnProperty.call(a.cache,b))return a.cache[b];var e=a.resolve(b);if(!e)throw new Error('Failed to resolve module '+b);var c={id:b,require:a,filename:b,exports:{},loaded:!1,parent:d,children:[]};d&&d.children.push(c);var f=b.slice(0,b.lastIndexOf('/')+1);return a.cache[b]=c.exports,e.call(c.exports,c,c.exports,f,b),c.loaded=!0,a.cache[b]=c.exports}a.modules={},a.cache={},a.resolve=function(b){return{}.hasOwnProperty.call(a.modules,b)?a.modules[b]:void 0},a.define=function(b,c){a.modules[b]=c},a.define('/lib/index.js',function(b,c,d,e){(function(){var k,g,p,o,n,i,l,h,j,m,f,e,c,q,d=[].slice;c=a('/lib/tools.js',b),k=a('/node_modules/es6-promise/dist/commonjs/main.js',b).Promise,j=c.pairs,n=c.keys,q=c.values,l=c.object,f=c.resolveAll,o=c.isPrimitive,p=c.isArray,h=c.objectCreate,m=c.proc,e=function(b,a){return f([b]).then(function(d){var b,c;return b=d[0],a<=0||b==null||o(b)?b:p(b)?f(b.map(function(b){return e(b,a-1)})):(c=f(q(b).map(function(b){return e(b,a-1)})),c.then(function(a){return l(n(b),a)}))})},g=function(g){var a,b,c,f;return b={},c={},f=function(){return j(b).forEach(function(a){var b,f;return f=a[0],b=a[1],c[f]=function(){var a;return a=1<=arguments.length?d.call(arguments,0):[],this.then(function(c){return e(a,1).then(function(a){return b.apply({value:c},a)})})}})},a=function(n,b){var i,j,f,k,l,m;b=(m=b!=null?b:g)!=null?m:{},b.depth===void 0&&(b.depth=1),b.depth===null&&(b.depth=1e6),f=e(n,b.depth),j=h(f),k=h(j),j.then=function(){var b;return b=1<=arguments.length?d.call(arguments,0):[],a(f.then.apply(f,b))};for(i in c)l=c[i],k[i]=l;return k},a.mixin=m(function(a){return j(a).forEach(function(d){var e,a,c;return a=d[0],e=d[1],c=b[a],b[a]=function(){var a;return a={value:this.value},c&&(a.base=c),e.apply(a,arguments)}}),f()}),a.bindSync=function(c,b){return function(){var e;return e=1<=arguments.length?d.call(arguments,0):[],a(e).then(function(a){return function(d){return c.apply(b!=null?b:a,d)}}(this))}},a.bindAsync=function(c,b){return function(){var e,f;return f=1<=arguments.length?d.call(arguments,0):[],e=b!=null?b:this,a(f).then(function(a){return new k(function(b,f){var g;a.push(function(){var c,a;return c=arguments[0],a=2<=arguments.length?d.call(arguments,1):[],c!=null?f(c):a.length===1?b(a[0]):b(a)});try{return c.apply(e,a)}catch(a){return g=a,f(g)}})})}},a},i=function(){var a;return a=g(),a.init=g,a},typeof window!=='undefined'&&window.require===void 0&&(window.Z=i()),b!==void 0&&(b.exports=i())}.call(this))}),a.define('/node_modules/es6-promise/dist/commonjs/main.js',function(b,a,c,d){(function(){var b;if(b=function(){return this.Promise}(),b==null)throw new Error('No native ES6-promises - Use a shim manually or via Z');a.Promise=b}.call(this))}),a.define('/lib/tools.js',function(c,b,d,e){(function(){var e,d={}.hasOwnProperty;e=a('/node_modules/es6-promise/dist/commonjs/main.js',c).Promise,b.pairs=function(b){var a,e,c;c=[];for(a in b){if(!d.call(b,a))continue;e=b[a],c.push([a,e])}return c},b.keys=function(b){var a,e,c;c=[];for(a in b){if(!d.call(b,a))continue;e=b[a],c.push(a)}return c},b.values=function(a){var b,e,c;c=[];for(b in a){if(!d.call(a,b))continue;e=a[b],c.push(e)}return c},b.object=function(d,g){var a,e,b,c,f;for(b={},a=c=0,f=d.length;c<f;a=++c)e=d[a],b[e]=g[a];return b},b.resolveAll=function(a){return e.all(a)},b.isPrimitive=function(a){var b;return b=['Function','String','Number','Date','RegExp','Boolean'],a===!0||a===!1?!0:b.some(function(b){return Object.prototype.toString.call(a)==='[object '+b+']'})},b.isArray=Array.isArray||function(a){return Object.prototype.toString.call(a)==='[object Array]'},b.objectCreate=Object.create||function(b){var a;return a=function(){},a.prototype=b,new a},b.proc=function(a){return function(){return void a.apply(this,arguments)}}}.call(this))}),b.Z=a('/lib/index.js')}.call(this,this))