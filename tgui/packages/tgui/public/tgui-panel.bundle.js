!function(e){function t(t){for(var r,a,s=t[0],c=t[1],u=t[2],l=0,p=[];l<s.length;l++)a=s[l],Object.prototype.hasOwnProperty.call(o,a)&&o[a]&&p.push(o[a][0]),o[a]=0;for(r in c)Object.prototype.hasOwnProperty.call(c,r)&&(e[r]=c[r]);for(d&&d(t);p.length;)p.shift()();return i.push.apply(i,u||[]),n()}function n(){for(var e,t=0;t<i.length;t++){for(var n=i[t],r=!0,s=1;s<n.length;s++){var c=n[s];0!==o[c]&&(r=!1)}r&&(i.splice(t--,1),e=a(a.s=n[0]))}return e}var r={},o={2:0},i=[];function a(t){if(r[t])return r[t].exports;var n=r[t]={i:t,l:!1,exports:{}};return e[t].call(n.exports,n,n.exports,a),n.l=!0,n.exports}a.m=e,a.c=r,a.d=function(e,t,n){a.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:n})},a.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},a.t=function(e,t){if(1&t&&(e=a(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var n=Object.create(null);if(a.r(n),Object.defineProperty(n,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var r in e)a.d(n,r,function(t){return e[t]}.bind(null,r));return n},a.n=function(e){var t=e&&e.__esModule?function(){return e["default"]}:function(){return e};return a.d(t,"a",t),t},a.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},a.p="";var s=window.webpackJsonp=window.webpackJsonp||[],c=s.push.bind(s);s.push=t,s=s.slice();for(var u=0;u<s.length;u++)t(s[u]);var d=c;i.push([623,0]),n()}({135:function(e,t,n){"use strict";t.__esModule=!0,t.canPageAcceptType=t.selectChatPageById=t.selectCurrentChatPage=t.selectChatPages=void 0;var r=n(13);t.selectChatPages=function(e){return(0,r.toArray)(e.chat.pageById)};t.selectCurrentChatPage=function(e){return e.chat.pageById[e.chat.currentPage]};t.selectChatPageById=function(e){return function(t){return t.chat.pageById[e]}};t.canPageAcceptType=function(e,t){return e.acceptedTypes[t]}},136:function(e,t,n){"use strict";t.__esModule=!0,t.selectSettings=void 0;t.selectSettings=function(e){return null==e?void 0:e.settings}},137:function(e,t,n){"use strict";t.__esModule=!0,t.loadSettings=t.toggleSettings=t.updateSettings=void 0;t.updateSettings=function(e){return void 0===e&&(e={}),{type:"settings/update",payload:e}};t.toggleSettings=function(){return{type:"settings/toggle"}};t.loadSettings=function(e){return void 0===e&&(e={}),{type:"settings/load",payload:e}}},398:function(e,t,n){"use strict";t.__esModule=!0,t.chatReducer=t.chatMiddleware=t.ChatTabs=t.ChatPanel=void 0;var r=n(627);t.ChatPanel=r.ChatPanel;var o=n(629);t.ChatTabs=o.ChatTabs;var i=n(630);t.chatMiddleware=i.chatMiddleware;var a=n(631);t.chatReducer=a.chatReducer},399:function(e,t,n){"use strict";t.__esModule=!0,t.chatRenderer=void 0;var r=n(400),o=n(135);function i(e,t){var n;if("undefined"==typeof Symbol||null==e[Symbol.iterator]){if(Array.isArray(e)||(n=function(e,t){if(!e)return;if("string"==typeof e)return a(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return a(e,t)}(e))||t&&e&&"number"==typeof e.length){n&&(e=n);var r=0;return function(){return r>=e.length?{done:!0}:{done:!1,value:e[r++]}}}throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}return(n=e[Symbol.iterator]()).next.bind(n)}function a(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}var s=new(function(){function e(){this.rootNode=null,this.queue=[],this.messages=[],this.page=r.DEFAULT_PAGE,this.onBatchProcesedSubscribers=[]}var t=e.prototype;return t.mount=function(e){if(!this.rootNode)return this.rootNode=e,this.queue=[],void this.processBatch(this.queue);e.appendChild(this.rootNode)},t.assignStyle=function(e){void 0===e&&(e={}),Object.assign(this.rootNode.style,e)},t.changePage=function(e){this.page=e,this.rootNode.textContent="";for(var t,n,r=document.createDocumentFragment(),a=i(this.messages);!(n=a()).done;){var s=n.value;(0,o.canPageAcceptType)(e,s.type)&&(t=s.node,r.appendChild(t))}t&&(this.rootNode.appendChild(r),t.scrollIntoView())},t.processBatch=function(e){if(this.rootNode){for(var t,n,a=document.createDocumentFragment(),s={},c=i(e);!(n=c()).done;){var u=n.value,d=Object.assign({},u);if((t=document.createElement("div")).innerHTML=d.text,d.node=t,!d.type){var l=r.MESSAGE_TYPES.find((function(e){return e.selector&&t.querySelector(e.selector)}));d.type=(null==l?void 0:l.type)||"unknown"}s[d.type]||(s[d.type]=0),s[d.type]+=1,this.messages.push(d),(0,o.canPageAcceptType)(this.page,d.type)&&a.appendChild(t)}t&&(this.rootNode.appendChild(a),t.scrollIntoView());for(var p,g=i(this.onBatchProcesedSubscribers);!(p=g()).done;)(0,p.value)(s)}else for(var f,h=i(e);!(f=h()).done;){var m=f.value;this.queue.push(m)}},t.onBatchProcesed=function(e){this.onBatchProcesedSubscribers.push(e)},e}());t.chatRenderer=s},400:function(e,t,n){"use strict";t.__esModule=!0,t.DEFAULT_PAGE=t.MESSAGE_TYPES=void 0;var r=n(628);function o(e,t){var n;if("undefined"==typeof Symbol||null==e[Symbol.iterator]){if(Array.isArray(e)||(n=function(e,t){if(!e)return;if("string"==typeof e)return i(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return i(e,t)}(e))||t&&e&&"number"==typeof e.length){n&&(e=n);var r=0;return function(){return r>=e.length?{done:!0}:{done:!1,value:e[r++]}}}throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}return(n=e[Symbol.iterator]()).next.bind(n)}function i(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}var a=[{type:"localchat",name:"Local Chat",description:"In-character local messages (say, emote, etc)",selector:".filter_say, .say, .emote",important:!1},{type:"radio",name:"Radio Comms",description:"All departments of radio messages",selector:".filter_radio, .alert, .syndradio, .centradio, .airadio, .entradio, .comradio, .secradio, .engradio, .medradio, .sciradio, .supradio, .srvradio, .expradio, .radio, .deptradio, .newscaster",important:!1},{type:"info",name:"Informational",description:"Non-urgent messages from the game and items",selector:".filter_notice, .notice:not(.pm), .adminnotice, .info, .sinister, .cult",important:!1},{type:"warnings",name:"Warnings",description:"Urgent messages from the game and items",selector:".filter_warning, .warning:not(.pm), .critical, .userdanger, .italics",important:!1},{type:"deadchat",name:"Deadchat",description:"All of deadchat",selector:".filter_deadsay, .deadsay",important:!1},{type:"globalooc",name:"Global OOC",description:"The bluewall of global OOC messages",selector:".filter_ooc, .ooc:not(.looc)",important:!1},{type:"adminpm",name:"Admin PMs",description:"Messages to/from admins (adminhelp)",selector:".filter_pm, .pm",important:!1},{type:"adminchat",name:"Admin Chat",description:"ASAY messages",selector:".filter_ASAY, .admin_channel",important:!1,admin:!0},{type:"modchat",name:"Mod Chat",description:"MSAY messages",selector:".filter_MSAY, .mod_channel",important:!1,admin:!0},{type:"eventchat",name:"Event Chat",description:"ESAY messages",selector:".filter_ESAY, .event_channel",important:!1,admin:!0},{type:"combat",name:"Combat Logs",description:"Urist McTraitor has stabbed you with a knife!",selector:".filter_combat, .danger",important:!1},{type:"adminlogs",name:"Admin Logs",description:"ADMIN LOG: Urist McAdmin has jumped to coordinates X, Y, Z",selector:".filter_adminlogs, .log_message",important:!1,admin:!0},{type:"attacklogs",name:"Attack Logs",description:"Urist McTraitor has shot John Doe",selector:".filter_attacklogs",important:!1,admin:!0},{type:"debuglogs",name:"Debug Logs",description:"DEBUG: SSPlanets subsystem Recover().",selector:".filter_debuglogs",important:!1,admin:!0},{type:"looc",name:"Local OOC",description:"Local OOC messages, always enabled",selector:".ooc.looc, .ooc, .looc",important:!0},{type:"system",name:"System Messages",description:"Messages from your client, always enabled",selector:".boldannounce, .filter_system",important:!0},{type:"unknown",name:"Unsorted Messages",description:"Everything we could not sort, always enabled",important:!0}];t.MESSAGE_TYPES=a;var s={id:(0,r.createUuid)(),name:"Main",acceptedTypes:function(){for(var e,t={},n=o(a);!(e=n()).done;){t[e.value.type]=!0}return t}(),count:0};t.DEFAULT_PAGE=s},401:function(e,t,n){"use strict";t.__esModule=!0,t.updateMessageCount=t.changeChatPage=void 0;t.changeChatPage=function(e){return{type:"chat/changePage",payload:{page:e}}};t.updateMessageCount=function(e){return{type:"chat/updateMessageCount",payload:{countByType:e}}}},402:function(e,t,n){"use strict";t.__esModule=!0,t.PingIndicator=t.pingMiddleware=t.pingReducer=t.selectPing=void 0;var r=n(0),o=n(632),i=n(14),a=n(1),s=n(2),c=n(34),u=n(56),d=function(e){return(null==e?void 0:e.ping)||{}};t.selectPing=d;t.pingReducer=function(e,t){void 0===e&&(e={});var n=t.type,r=t.payload;if("ping/success"===n){var o=r.roundtrip,a=e.roundtripAvg||o,s=Math.round(.4*a+.6*o);return{roundtrip:o,roundtripAvg:s,failCount:0,networkQuality:1-(0,i.scale)(s,40,120)}}if("ping/fail"===n){var c=e.failCount,u=void 0===c?0:c,d=(0,i.clamp01)(e.networkQuality-u/3),l=Object.assign({},e,{failCount:u+1,networkQuality:d});return u>3&&(l.roundtrip=undefined,l.roundtripAvg=undefined),l}return e};t.pingMiddleware=function(e){var t=0,n=[],r=function(){for(var r=0;r<8;r++){var o=n[r];o&&Date.now()-o.sentAt>2e3&&(n[r]=null,e.dispatch({type:"ping/fail"}))}var i={index:t,sentAt:Date.now()};n[t]=i,(0,a.sendMessage)({type:"ping",payload:{index:t}}),t=(t+1)%8};return setInterval(r,2e3),r(),function(e){return function(t){var r=t.type,o=t.payload;if("pingReply"===r){var i=o.index,a=n[i];return a?(n[i]=null,e(function(e){var t=.5*(Date.now()-e.sentAt);return{type:"ping/success",payload:{lastId:e.id,roundtrip:t}}}(a))):void c.logger.log("Received a timed out ping.")}return e(t)}}};t.PingIndicator=function(e,t){var n=(0,u.useSelector)(t,d);return(0,r.createComponentVNode)(2,s.Box,{textColor:o.Color.lookup(n.networkQuality,[new o.Color(219,40,40),new o.Color(251,214,8),new o.Color(32,177,66)]),children:[n.roundtripAvg||"--"," ms"]})}},403:function(e,t,n){"use strict";t.__esModule=!0,t.SettingsPanel=t.settingsReducer=t.settingsMiddleware=t.useSettings=void 0;var r=n(633);t.useSettings=r.useSettings;var o=n(634);t.settingsMiddleware=o.settingsMiddleware;var i=n(635);t.settingsReducer=i.settingsReducer;var a=n(636);t.SettingsPanel=a.SettingsPanel},623:function(e,t,n){e.exports=n(624)},624:function(e,t,n){"use strict";n(138),n(150),n(151),n(152),n(153),n(154),n(155),n(156),n(157),n(158),n(159),n(160),n(161),n(162),n(163),n(164),n(166),n(167),n(168),n(169),n(170),n(171),n(173),n(174),n(175),n(177),n(178),n(179),n(110),n(182),n(183),n(185),n(186),n(187),n(188),n(189),n(190),n(191),n(192),n(193),n(194),n(195),n(196),n(198),n(199),n(200),n(201),n(202),n(203),n(204),n(205),n(206),n(208),n(209),n(210),n(211),n(213),n(215),n(216),n(217),n(218),n(219),n(220),n(221),n(222),n(223),n(224),n(225),n(226),n(227),n(228),n(229),n(230),n(231),n(232),n(233),n(234),n(235),n(237),n(238),n(239),n(240),n(241),n(242),n(244),n(245),n(246),n(247),n(248),n(249),n(250),n(251),n(253),n(254),n(255),n(256),n(257),n(258),n(259),n(261),n(262),n(263),n(264),n(265),n(266),n(267),n(268),n(269),n(270),n(271),n(272),n(273),n(279),n(280),n(281),n(282),n(283),n(284),n(285),n(286),n(287),n(288),n(289),n(290),n(291),n(292),n(293),n(120),n(294),n(295),n(296),n(297),n(298),n(299),n(300),n(301),n(302),n(303),n(305),n(306),n(307),n(308),n(309),n(310),n(311),n(312),n(313),n(314),n(315),n(316),n(317),n(318),n(319),n(320),n(321),n(322),n(323),n(324),n(325),n(326),n(327),n(328),n(331),n(332),n(333),n(334),n(335),n(336),n(337),n(338),n(339),n(340),n(341),n(342),n(343),n(344),n(345),n(346),n(347),n(348),n(349),n(350),n(351),n(352),n(353),n(354),n(355),n(356),n(357),n(358),n(359),n(360),n(361),n(362),n(363),n(364),n(366),n(367),n(368),n(369);var r=n(0);n(370),n(371),n(372),n(373),n(374),n(375),n(625),n(626);var o=n(92),i=n(376),a=(n(127),n(128)),s=n(56),c=n(398),u=n(402),d=n(403),l=n(34);o.perf.mark("inception",window.__inception__),o.perf.mark("init");var p=(0,s.configureStore)({reducer:(0,i.combineReducers)({chat:c.chatReducer,ping:u.pingReducer,settings:d.settingsReducer}),middleware:{pre:[c.chatMiddleware,u.pingMiddleware,d.settingsMiddleware]}}),g=(0,a.createRenderer)((function(){var e=n(637).Panel;return(0,r.createComponentVNode)(2,s.StoreProvider,{store:p,children:(0,r.createComponentVNode)(2,e)})}));l.logger.log("Hello!");!function f(){if("loading"!==document.readyState){for(p.subscribe(g),window.update=function(e){return p.dispatch(Byond.parseJson(e))};;){var e=window.__updateQueue__.shift();if(!e)break;window.update(e)}Byond.winset("output",{"is-visible":!1}),Byond.winset("browseroutput",{"is-visible":!0,"is-disabled":!1,size:"0x0"})}else document.addEventListener("DOMContentLoaded",f)}()},625:function(e,t,n){},626:function(e,t,n){},627:function(e,t,n){"use strict";t.__esModule=!0,t.ChatPanel=void 0;var r=n(0),o=n(6),i=n(399);var a=function(e){var t,n;function a(){var t;return(t=e.call(this)||this).ref=(0,r.createRef)(),t}n=e,(t=a).prototype=Object.create(n.prototype),t.prototype.constructor=t,t.__proto__=n;var s=a.prototype;return s.componentDidMount=function(){i.chatRenderer.mount(this.ref.current),this.componentDidUpdate()},s.shouldComponentUpdate=function(e){return(0,o.shallowDiffers)(this.props,e)},s.componentDidUpdate=function(){i.chatRenderer.assignStyle({width:"100%",whiteSpace:"pre-wrap",fontSize:this.props.fontSize,lineHeight:this.props.lineHeight})},s.render=function(){return(0,r.createVNode)(1,"div",null,null,1,null,null,this.ref)},a}(r.Component);t.ChatPanel=a},628:function(e,t,n){"use strict";t.__esModule=!0,t.createUuid=void 0;t.createUuid=function(){var e=(new Date).getTime();return"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,(function(t){var n=(e+16*Math.random())%16|0;return e=Math.floor(e/16),("x"===t?n:3&n|8).toString(16)}))}},629:function(e,t,n){"use strict";t.__esModule=!0,t.ChatTabs=void 0;var r=n(0),o=n(2),i=n(56),a=n(401),s=n(135);t.ChatTabs=function(e,t){var n=(0,i.useSelector)(t,s.selectChatPages),c=(0,i.useSelector)(t,s.selectCurrentChatPage),u=(0,i.useDispatch)(t);return(0,r.createComponentVNode)(2,o.Tabs,{textAlign:"center",children:n.map((function(e){return(0,r.createComponentVNode)(2,o.Tabs.Tab,{selected:e===c,rightSlot:(0,r.createComponentVNode)(2,o.Box,{fontSize:"0.9em",children:e.count}),onClick:function(){return u((0,a.changeChatPage)(e))},children:e.name},e.id)}))})}},630:function(e,t,n){"use strict";t.__esModule=!0,t.chatMiddleware=void 0;var r=n(401),o=n(399);t.chatMiddleware=function(e){return o.chatRenderer.onBatchProcesed((function(t){e.dispatch((0,r.updateMessageCount)(t))})),function(e){return function(t){var n=t.type,r=t.payload;if("chat/message"!==n){if("chat/changePage"===n){var i=r.page;return o.chatRenderer.changePage(i),e(t)}return e(t)}var a=Array.isArray(r)?r:[r];o.chatRenderer.processBatch(a)}}}},631:function(e,t,n){"use strict";t.__esModule=!0,t.chatReducer=t.initialState=void 0;var r,o=n(13),i=n(400),a=n(135);function s(e,t){var n;if("undefined"==typeof Symbol||null==e[Symbol.iterator]){if(Array.isArray(e)||(n=function(e,t){if(!e)return;if("string"==typeof e)return c(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return c(e,t)}(e))||t&&e&&"number"==typeof e.length){n&&(e=n);var r=0;return function(){return r>=e.length?{done:!0}:{done:!1,value:e[r++]}}}throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}return(n=e[Symbol.iterator]()).next.bind(n)}function c(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}var u={currentPage:i.DEFAULT_PAGE.id,pageById:(r={},r[i.DEFAULT_PAGE.id]=i.DEFAULT_PAGE,r)};t.initialState=u;t.chatReducer=function(e,t){void 0===e&&(e=u);var n=t.type,r=t.payload;if("chat/changePage"===n){var i=r.page;return Object.assign({},e,{currentPage:i.id})}if("chat/updateMessageCount"===n){for(var c,d=r.countByType,l=(0,o.toArray)(e.pageById),p=Object.assign({},e.pageById),g=s(l);!(c=g()).done;){for(var f=c.value,h=f.count||0,m=0,v=Object.keys(d);m<v.length;m++){var y=v[m];(0,a.canPageAcceptType)(f,y)&&(h+=d[y])}f.count!==h&&(p[f.id]=Object.assign({},f,{count:h}))}return Object.assign({},e,{pageById:p})}return e}},632:function(e,t,n){"use strict";t.__esModule=!0,t.Color=void 0;var r=function(){function e(e,t,n,r){void 0===e&&(e=0),void 0===t&&(t=0),void 0===n&&(n=0),void 0===r&&(r=1),Object.assign(this,{r:e,g:t,b:n,a:r})}return e.prototype.toString=function(){return"rgba("+(0|this.r)+", "+(0|this.g)+", "+(0|this.b)+", "+(0|this.a)+")"},e}();t.Color=r,r.fromHex=function(e){return new r(parseInt(e.substr(1,2),16),parseInt(e.substr(3,2),16),parseInt(e.substr(5,2),16))},r.lerp=function(e,t,n){return new r((t.r-e.r)*n+e.r,(t.g-e.g)*n+e.g,(t.b-e.b)*n+e.b,(t.a-e.a)*n+e.a)},r.lookup=function(e,t){void 0===t&&(t=[]);var n=t.length;if(n<2)throw new Error("Needs at least two colors!");var o=e*(n-1);if(e<1e-4)return t[0];if(e>=.9999)return t[n-1];var i=o%1,a=0|o;return r.lerp(t[a],t[a+1],i)}},633:function(e,t,n){"use strict";t.__esModule=!0,t.useSettings=void 0;var r=n(56),o=n(136),i=n(137);t.useSettings=function(e){var t=(0,r.useSelector)(e,o.selectSettings),n=(0,r.useDispatch)(e);return Object.assign({},t,{toggle:function(){return n((0,i.toggleSettings)())}})}},634:function(e,t,n){"use strict";t.__esModule=!0,t.settingsMiddleware=t.sendChangeTheme=void 0;var r=n(378),o=n(1),i=n(137),a=n(136),s=function(e){return(0,o.sendMessage)({type:"changeTheme",payload:{name:e}})};t.sendChangeTheme=s;t.settingsMiddleware=function(e){var t=!1;return function(n){return function(o){var c=o.type,u=o.payload;if(t){if("settings/update"===c){var d=u.theme;return d&&s(d),n(o),void r.storage.set("panel-settings",(0,a.selectSettings)(e.getState()))}return n(o)}n(o),t=!0;var l=r.storage.get("panel-settings");if(l){var p=l.theme;p&&s(p),e.dispatch((0,i.loadSettings)(l))}}}}},635:function(e,t,n){"use strict";t.__esModule=!0,t.settingsReducer=void 0;var r={visible:!1,fontSize:12,lineHeight:1.5,theme:"dark"};t.settingsReducer=function(e,t){void 0===e&&(e=r);var n=t.type,o=t.payload;if("settings/update"===n)return Object.assign({},e,o);if("settings/load"===n){var i=o;return Object.assign({},e,{fontSize:i.fontSize,lineHeight:i.lineHeight,theme:i.theme})}return"settings/toggle"===n?Object.assign({},e,{visible:!e.visible}):e}},636:function(e,t,n){"use strict";t.__esModule=!0,t.SettingsPanel=void 0;var r=n(0),o=n(14),i=n(2),a=n(56),s=n(137),c=n(136);t.SettingsPanel=function(e,t){var n=(0,a.useSelector)(t,c.selectSettings),u=n.theme,d=n.fontSize,l=n.lineHeight,p=(0,a.useDispatch)(t);return(0,r.createComponentVNode)(2,i.Section,{children:(0,r.createComponentVNode)(2,i.LabeledList,{children:[(0,r.createComponentVNode)(2,i.LabeledList.Item,{label:"Theme",children:(0,r.createComponentVNode)(2,i.Dropdown,{selected:u,options:["light","dark"],onSelected:function(e){return p((0,s.updateSettings)({theme:e}))}})}),(0,r.createComponentVNode)(2,i.LabeledList.Item,{label:"Font size",children:(0,r.createComponentVNode)(2,i.NumberInput,{width:"4em",step:1,stepPixelSize:10,minValue:8,maxValue:36,value:d,unit:"pt",format:function(e){return(0,o.toFixed)(e)},onChange:function(e,t){return p((0,s.updateSettings)({fontSize:t}))}})}),(0,r.createComponentVNode)(2,i.LabeledList.Item,{label:"Line height",children:(0,r.createComponentVNode)(2,i.NumberInput,{width:"4em",step:.01,stepPixelSize:2,minValue:1,maxValue:4,value:l,format:function(e){return(0,o.toFixed)(e,2)},onChange:function(e,t){return p((0,s.updateSettings)({lineHeight:t}))}})})]})})}},637:function(e,t,n){"use strict";t.__esModule=!0,t.Panel=void 0;var r=n(0),o=n(2),i=n(3),a=n(398),s=n(402),c=n(403);t.Panel=function(e,t){var n=(0,c.useSettings)(t);return(0,r.createComponentVNode)(2,i.Pane,{theme:n.theme,fontSize:n.fontSize+"pt",children:(0,r.createComponentVNode)(2,o.Flex,{direction:"column",height:"100%",children:[(0,r.createComponentVNode)(2,o.Flex.Item,{children:(0,r.createComponentVNode)(2,o.Section,{fitted:!0,children:(0,r.createComponentVNode)(2,o.Flex,{align:"center",children:[(0,r.createComponentVNode)(2,o.Flex.Item,{mx:1,grow:1,children:(0,r.createComponentVNode)(2,a.ChatTabs)}),(0,r.createComponentVNode)(2,o.Flex.Item,{mx:1,children:(0,r.createComponentVNode)(2,s.PingIndicator)}),(0,r.createComponentVNode)(2,o.Flex.Item,{mx:1,children:(0,r.createComponentVNode)(2,o.Button,{icon:"cog",onClick:function(){return n.toggle()}})})]})})}),n.visible&&(0,r.createComponentVNode)(2,o.Flex.Item,{position:"relative",grow:1,children:(0,r.createComponentVNode)(2,i.Pane.Content,{scrollable:!0,children:(0,r.createComponentVNode)(2,c.SettingsPanel)})})||(0,r.createComponentVNode)(2,o.Flex.Item,{mt:1,grow:1,children:(0,r.createComponentVNode)(2,o.Section,{fill:!0,fitted:!0,position:"relative",children:(0,r.createComponentVNode)(2,i.Pane.Content,{scrollable:!0,children:(0,r.createComponentVNode)(2,a.ChatPanel,{lineHeight:n.lineHeight})})})})]})})}}});