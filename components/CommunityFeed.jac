sv import from ..services.communityService { CommunityPost, get_posts, create_post, vote_post }
import from .ui.button { Button }
import from .ui.card { Card, CardContent }
import from .ui.input { Input }
import from .ui.textarea { Textarea }
import from .ui.badge { Badge }
import from "@jac/runtime" { Link }


def:pub CommunityFeed() -> JsxElement {
    has posts: list[CommunityPost] = [];
    has title: str = "";
    has body: str = "";
    has community: str = "general";
    has loading: bool = True;
    has error: str = "";
    has active_tab: str = "Popular";

    async can with entry {
        try {
            posts = await get_posts();
            loading = False;
        } except Exception {
            error = "The community feed could not load.";
            loading = False;
        }
    }

    def handle_title(e: ChangeEvent) { title = e.target.value; }
    def handle_body(e: ChangeEvent) { body = e.target.value; }
    def handle_community(e: ChangeEvent) { community = e.target.value; }
    def handle_tab(e: MouseEvent) { active_tab = "Popular"; }
    def handle_new(e: MouseEvent) { active_tab = "New"; }

    async def handle_submit(e: FormEvent) -> None {
        e.preventDefault();
        error = "";
        if len(title.strip()) == 0 or len(body.strip()) == 0 {
            error = "Add a title and some text before posting.";
            return;
        }
        try {
            post = await create_post(title, body, community);
            if post is None {
                error = "Check your post details and try again.";
                return;
            }
            posts = [post] + posts;
            title = "";
            body = "";
            active_tab = "New";
        } except Exception {
            error = "Your post could not be published. Please try again.";
        }
    }

    async def handle_vote(post_id: str, direction: int) -> None {
        try {
            updated = await vote_post(post_id, direction);
            if updated is not None {
                posts = [updated if jid(p) == post_id else p for p in posts];
            }
        } except Exception {
            error = "Your vote could not be saved. Please try again.";
        }
    }

    return <div className="min-h-screen bg-muted/40 text-foreground">
        <header className="sticky top-0 z-20 border-b bg-background/95 shadow-sm backdrop-blur">
            <div className="mx-auto flex h-16 max-w-[1400px] items-center gap-4 px-4 sm:px-6">
                <Link to="/" className="flex shrink-0 items-center gap-2.5">
                    <span className="flex size-9 items-center justify-center rounded-full bg-primary text-lg font-bold text-primary-foreground">r</span>
                    <span className="hidden text-xl font-bold tracking-tight sm:inline">reddit</span>
                </Link>
                <div className="hidden h-9 flex-1 items-center rounded-full border bg-muted/70 px-4 text-sm text-muted-foreground sm:flex">Search communities</div>
                <Button variant="outline" size="sm" className="ml-auto rounded-full">Log in</Button>
                <Button size="sm" className="rounded-full">Sign up</Button>
            </div>
        </header>
        <div className="mx-auto grid max-w-[1400px] grid-cols-1 gap-6 px-4 py-6 sm:px-6 lg:grid-cols-[220px_minmax(0,1fr)_300px]">
            <aside className="hidden lg:block">
                <div className="sticky top-24 flex flex-col gap-5">
                    <div className="rounded-xl border bg-card p-3 shadow-sm">
                        <p className="px-3 pb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">Feeds</p>
                        <button onClick={handle_tab} className="flex w-full items-center gap-3 rounded-lg bg-primary/10 px-3 py-2.5 text-left text-sm font-semibold text-primary">⌂ <span>Home</span></button>
                        <button onClick={handle_tab} className="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm text-muted-foreground hover:bg-muted">↗ <span>Popular</span></button>
                    </div>
                    <div className="rounded-xl border bg-card p-3 shadow-sm">
                        <p className="px-3 pb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">Your communities</p>
                        <a className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm hover:bg-muted"><span className="flex size-7 items-center justify-center rounded-full bg-amber-100 text-xs font-bold text-amber-800">c</span> casualconversation</a>
                        <a className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm hover:bg-muted"><span className="flex size-7 items-center justify-center rounded-full bg-sky-100 text-xs font-bold text-sky-800">k</span> MechanicalKeyboards</a>
                        <a className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm hover:bg-muted"><span className="flex size-7 items-center justify-center rounded-full bg-emerald-100 text-xs font-bold text-emerald-800">b</span> books</a>
                        <a className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm hover:bg-muted"><span className="flex size-7 items-center justify-center rounded-full bg-violet-100 text-xs font-bold text-violet-800">s</span> science</a>
                    </div>
                </div>
            </aside>
            <main className="min-w-0">
                <div className="mb-5 flex flex-wrap items-end justify-between gap-3">
                    <div><h1 className="text-2xl font-semibold tracking-tight">Good afternoon</h1><p className="mt-1 text-sm text-muted-foreground">The internet, gathered in one place.</p></div>
                    <Badge variant="secondary" className="rounded-full px-3 py-1">Front page</Badge>
                </div>
                <form onSubmit={handle_submit} className="mb-5 rounded-xl border bg-card p-4 shadow-sm">
                    <div className="mb-3 flex items-center gap-3">
                        <span className="flex size-9 items-center justify-center rounded-full bg-primary/10 font-semibold text-primary">Y</span>
                        <Input value={title} onChange={handle_title} placeholder="Create a post" aria-label="Post title" className="h-10 rounded-full bg-muted/50" />
                    </div>
                    <div className="flex flex-col gap-3">
                        <Input value={community} onChange={handle_community} placeholder="Community (e.g. general)" aria-label="Community" className="h-9" />
                        <Textarea value={body} onChange={handle_body} placeholder="What would you like to share?" aria-label="Post text" className="min-h-20 resize-y" />
                        <div className="flex flex-wrap items-center justify-between gap-3">
                            <span className="text-xs text-muted-foreground">Share something worth discussing.</span>
                            <Button type="submit" className="rounded-full px-5">Post</Button>
                        </div>
                        {if error != "" { <p role="alert" className="text-sm text-destructive">{error}</p> }}
                    </div>
                </form>
                <div className="mb-3 flex items-center gap-2 rounded-xl border bg-card p-2 shadow-sm">
                    <button onClick={handle_tab} className={"rounded-full px-4 py-2 text-sm font-semibold transition-colors " + ("bg-primary/10 text-primary" if active_tab == "Popular" else "text-muted-foreground hover:bg-muted")}>Popular</button>
                    <button onClick={handle_new} className={"rounded-full px-4 py-2 text-sm font-semibold transition-colors " + ("bg-primary/10 text-primary" if active_tab == "New" else "text-muted-foreground hover:bg-muted")}>New</button>
                    <span className="ml-auto hidden px-3 text-xs text-muted-foreground sm:inline">Sort by {active_tab.lower()}</span>
                </div>
                {if loading {
                    <div className="flex flex-col gap-3"><div className="h-40 animate-pulse rounded-xl border bg-card" /><div className="h-40 animate-pulse rounded-xl border bg-card" /><div className="h-40 animate-pulse rounded-xl border bg-card" /></div>
                } elif error != "" and len(posts) == 0 {
                    <Card className="shadow-sm"><CardContent className="p-8 text-center"><p className="font-medium">The feed is unavailable</p><p className="mt-1 text-sm text-muted-foreground">{error}</p></CardContent></Card>
                } elif len(posts) == 0 {
                    <Card className="shadow-sm"><CardContent className="p-10 text-center"><p className="text-lg font-semibold">It’s quiet around here</p><p className="mt-2 text-sm text-muted-foreground">Start the conversation with the first post.</p></CardContent></Card>
                } else {
                    <div className="flex flex-col gap-3">
                        {for post in posts {
                            <article key={jid(post)} className="group flex overflow-hidden rounded-xl border bg-card shadow-sm transition-shadow hover:shadow-md">
                                <div className="flex w-12 shrink-0 flex-col items-center gap-1 bg-muted/40 py-4 sm:w-14">
                                    <button aria-label="Upvote" onClick={lambda { handle_vote(jid(post), 1); }} className="rounded p-1 text-muted-foreground transition-colors hover:bg-primary/10 hover:text-primary">▲</button>
                                    <span className="text-xs font-bold tabular-nums">{post.votes}</span>
                                    <button aria-label="Downvote" onClick={lambda { handle_vote(jid(post), -1); }} className="rounded p-1 text-muted-foreground transition-colors hover:bg-primary/10 hover:text-primary">▼</button>
                                </div>
                                <div className="min-w-0 flex-1 p-4 sm:p-5">
                                    <div className="mb-2 flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-muted-foreground">
                                        <span className="font-semibold text-foreground">r/{post.community}</span><span>·</span><span>Posted by u/{post.author}</span><span>{post.age}</span>
                                    </div>
                                    <h2 className="text-lg font-semibold leading-snug tracking-tight">{post.title}</h2>
                                    <p className="mt-2 line-clamp-3 text-sm leading-relaxed text-muted-foreground">{post.body}</p>
                                    <div className="mt-4 flex items-center gap-2">
                                        <Button variant="secondary" size="sm" className="rounded-full text-xs">{str(post.comments)} comments</Button>
                                        <Button variant="ghost" size="sm" className="rounded-full text-xs text-muted-foreground">Share</Button>
                                    </div>
                                </div>
                            </article>
                        }}
                    </div>
                }}
            </main>
            <aside className="hidden lg:block">
                <div className="sticky top-24 flex flex-col gap-4">
                    <Card className="overflow-hidden shadow-sm">
                        <div className="h-20 bg-primary/15" />
                        <CardContent className="-mt-5 p-4">
                            <div className="mb-3 flex size-10 items-center justify-center rounded-full border-4 border-card bg-primary text-lg font-bold text-primary-foreground">r</div>
                            <h2 className="font-semibold">Home</h2>
                            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">Reddit is a place to discover communities, share what you love, and join the conversation.</p>
                            <Button className="mt-4 w-full rounded-full">Create a post</Button>
                        </CardContent>
                    </Card>
                    <div className="rounded-xl border bg-card p-4 text-xs leading-relaxed text-muted-foreground shadow-sm">About · Careers · Press · Terms · Privacy<br /><span className="mt-2 inline-block">Reddit, Inc. © 2025</span></div>
                </div>
            </aside>
        </div>
    </div>;
}
