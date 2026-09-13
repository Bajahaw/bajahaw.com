(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    const depth = (url) => {
        try {
            let path = new URL(url, location.origin).pathname;
            path = path.replace(/\/index\.html$/i, "").replace(/\/+$/, "") || "/";
            if (path === "/") return 0;
            return path.split("/").filter(Boolean).length;
        } catch {
            return 0;
        }
    };

    const typeFor = (from, to) => (depth(to) < depth(from) ? "back" : "forward");

    window.addEventListener("pageswap", (e) => {
        if (!e.viewTransition || !e.activation) return;
        const from = e.activation.from?.url ?? location.href;
        const to = e.activation.entry?.url;
        if (!to) return;
        e.viewTransition.types.add(typeFor(from, to));
    });

    window.addEventListener("pagereveal", (e) => {
        if (!e.viewTransition) return;
        const act = window.navigation?.activation;
        const from = act?.from?.url;
        const to = act?.entry?.url ?? location.href;
        e.viewTransition.types.add(from ? typeFor(from, to) : "forward");
    });
})();
