const tagAttr = "AcBlog_Extensions_Core_Tag";
const cacheNamePrefix = 'offline-cache-';

window.AcBlog_Extensions_Core = {
    cacheDataFromPath: async function (path, forceUpdate) {
        const cacheKeys = await caches.keys();
        const keys = cacheKeys.filter(key => key.startsWith(cacheNamePrefix));
        if (keys.length == 0) {
            // No cache
        }
        else {
            const key = keys[0];
            const cache = await caches.open(key);
            var req = new Request(path);
            if (forceUpdate || (!cache.match(req))) {
                await cache.add(req);
            }
        }
    },
    loadScript: function (src) {
        var scs = document.getElementsByTagName("script");
        for (var i = 0; i < scs.length; i++) {
            if (scs[i].hasAttribute(tagAttr)) {
                if (scs[i].getAttribute(tagAttr) == src)
                    return;
            }
        }

        return new Promise((resolve, reject) => {
            var script = document.createElement('script');
            script.src = src;
            script.type = "text/javascript";

            script.onload = function () {
                resolve()
            }
            script.onerror = function (error) {
                reject(error)
            }
            script.setAttribute(tagAttr, src);

            document.body.appendChild(script);
        })
    },
    loadStyleSheet: function (href) {
        var lks = document.getElementsByTagName("link");
        for (var i = 0; i < lks.length; i++) {
            if (lks[i].hasAttribute(tagAttr)) {
                if (lks[i].getAttribute(tagAttr) == href)
                    return;
            }
        }

        var link = document.createElement('link');
        link.rel = "stylesheet";
        link.type = "text/css";
        link.href = href;
        link.setAttribute(tagAttr, href);
        document.head.appendChild(link);
    }
};