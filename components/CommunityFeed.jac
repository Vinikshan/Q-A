sv import from ..services.communityService { CommunityPost, get_posts, create_post, vote_post }
import from .ui.button { Button }
import from .ui.card { Card, CardContent }
import from .ui.input { Input }
import from .ui.textarea { Textarea }
import from .ui.badge { Badge }
import from .AnswerThread { AnswerThread }
import from "@jac/runtime" { Link, jacIsLoggedIn, jacLogout }



def post_popularity(post: CommunityPost) -> int {
    return post.answer_count * 100000 + post.votes;
}

def:pub CommunityFeed() -> JsxElement {
    has posts: list[CommunityPost] = [];
    has title: str = "";
    has body: str = "";
    has community: str = "general";
    has loading: bool = True;
    has error: str = "";
    has active_tab: str = "Popular";
    has search_query: str = "";
    signed_in = jacIsLoggedIn();
    query = search_query.strip().lower();
    visible_posts = [post for post in posts if query == "" or query in post.title.lower() or query in post.body.lower() or query in post.community.lower() or query in post.author.lower()];
    if active_tab == "Popular" {
        visible_posts = sorted(visible_posts, key=post_popularity, reverse=True);
    } else {
        visible_posts = [post for post in reversed(visible_posts)];
    }

    async can with entry {
        try {
            posts = await get_posts();
            active_tab = "Popular";
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
    def handle_search(e: ChangeEvent) { search_query = e.target.value; }
    def filter_topic(topic_name: str) { search_query = topic_name; }

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

    return <div className="min-h-screen bg-[radial-gradient(ellipse_at_top,rgba(16,185,129,0.12),transparent_42%),radial-gradient(ellipse_at_bottom_right,rgba(16,185,129,0.06),transparent_38%)] bg-background text-foreground">
        <header className="sticky top-0 z-20 border-b border-primary/15 bg-background/55 shadow-lg shadow-primary/5 backdrop-blur-2xl">
            <div className="mx-auto flex h-16 max-w-[1400px] items-center gap-4 px-4 sm:px-6">
                <Link to="/" className="flex shrink-0 items-center gap-2.5">
                    <span className="flex size-9 items-center justify-center rounded-xl bg-primary text-lg font-bold text-primary-foreground shadow-lg shadow-primary/30 ring-1 ring-primary-foreground/20">Q</span>
                    <span className="text-lg font-bold tracking-tight text-primary sm:text-xl">Q&amp;A Finder</span>
                </Link>
                <div className="hidden h-10 flex-1 sm:block"><Input type="search" value={search_query} onChange={handle_search} placeholder="Search questions, topics, and people" aria-label="Search questions" className="h-10 w-full rounded-full bg-muted/70 px-4" /></div>
                {if signed_in {
                    <div className="ml-auto flex items-center gap-2"><Button variant="outline" size="sm" onClick={lambda { jacLogout(); }}>Sign out</Button></div>
                } else {
                    <Link to="/account" className="ml-auto"><Button variant="outline" size="sm" className="rounded-full">Sign in</Button></Link>
                }}
            </div>
            <div className="px-4 pb-3 sm:hidden"><Input type="search" value={search_query} onChange={handle_search} placeholder="Search questions, topics, and people" aria-label="Search questions" className="h-10 w-full rounded-full bg-muted/70 px-4" /></div>
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
                        <div className="flex items-center justify-between px-3 pb-2"><p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Explore topics</p>{if query != "" { <button onClick={lambda { filter_topic(""); }} className="text-xs text-primary hover:underline">Clear</button> }}</div>
                        <button onClick={lambda { filter_topic("Everyday"); }} className={"flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm " + ("bg-primary/10 text-primary" if "everyday" in query else "hover:bg-muted")}><span className="flex size-7 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">e</span> Everyday</button>
                        <button onClick={lambda { filter_topic("Technology"); }} className={"flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm " + ("bg-primary/10 text-primary" if "technology" in query else "hover:bg-muted")}><span className="flex size-7 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">t</span> Technology</button>
                        <button onClick={lambda { filter_topic("Books"); }} className={"flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm " + ("bg-primary/10 text-primary" if "books" in query else "hover:bg-muted")}><span className="flex size-7 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">b</span> Books</button>
                        <button onClick={lambda { filter_topic("Science"); }} className={"flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm " + ("bg-primary/10 text-primary" if "science" in query else "hover:bg-muted")}><span className="flex size-7 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">s</span> Science</button>
                    </div>
                </div>
            </aside>
            <main className="min-w-0">
                <div className="mb-5 flex flex-wrap items-end justify-between gap-3">
                    <div><h1 className="text-2xl font-semibold tracking-tight text-primary">Q&amp;A Finder</h1><p className="mt-1 text-sm text-muted-foreground">Ask thoughtful questions. Find answers from people who know.</p></div>
                    <Badge variant="secondary" className="rounded-full px-3 py-1">Community questions</Badge>
                </div>
                {if signed_in {
                    <form onSubmit={handle_submit} className="mb-5 rounded-xl border border-border/70 bg-card/70 p-4 shadow-lg shadow-black/10 backdrop-blur-xl transition-all duration-300 hover:border-primary/30 hover:shadow-primary/5">
                        <div className="mb-3 flex items-center gap-3"><span className="flex size-9 items-center justify-center rounded-full bg-primary/10 font-semibold text-primary">Q</span><Input value={title} onChange={handle_title} placeholder="Ask a question" aria-label="Question title" className="h-10 rounded-full bg-muted/50" /></div>
                        <div className="flex flex-col gap-3"><Input value={community} onChange={handle_community} placeholder="Topic (e.g. general)" aria-label="Topic" className="h-9" /><Textarea value={body} onChange={handle_body} placeholder="Add context or details for your question" aria-label="Question details" className="min-h-20 resize-y" /><div className="flex flex-wrap items-center justify-between gap-3"><span className="text-xs text-muted-foreground">Good questions help everyone learn.</span><Button type="submit" className="rounded-full px-5">Ask question</Button></div>{if error != "" { <p role="alert" className="text-sm text-destructive">{error}</p> }}</div>
                    </form>
                } else {
                    <div className="mb-5 flex flex-wrap items-center justify-between gap-3 rounded-xl border bg-card p-4 shadow-sm"><p className="text-sm text-muted-foreground">Join Q&amp;A Finder to ask a question or vote on helpful answers.</p><Link to="/account"><Button className="rounded-full">Create an account</Button></Link></div>
                }}
                <div className="mb-3 flex items-center gap-2 rounded-xl border border-primary/15 bg-card/55 p-2 shadow-lg shadow-black/15 backdrop-blur-xl transition-all duration-300 hover:border-primary/25">
                    <button onClick={handle_tab} className={"rounded-full px-4 py-2 text-sm font-semibold transition-colors " + ("bg-primary/10 text-primary" if active_tab == "Popular" else "text-muted-foreground hover:bg-muted")}>Popular</button>
                    <button onClick={handle_new} className={"rounded-full px-4 py-2 text-sm font-semibold transition-colors " + ("bg-primary/10 text-primary" if active_tab == "New" else "text-muted-foreground hover:bg-muted")}>New</button>
                    <span className="ml-auto hidden px-3 text-xs text-muted-foreground sm:inline">Sort by {active_tab.lower()}</span>
                </div>
                {if loading {
                    <div className="flex flex-col gap-3"><div className="h-40 animate-pulse rounded-xl border bg-card" /><div className="h-40 animate-pulse rounded-xl border bg-card" /><div className="h-40 animate-pulse rounded-xl border bg-card" /></div>
                } elif error != "" and len(posts) == 0 {
                    <Card className="shadow-sm"><CardContent className="p-8 text-center"><p className="font-medium">The feed is unavailable</p><p className="mt-1 text-sm text-muted-foreground">{error}</p></CardContent></Card>
                } elif len(visible_posts) == 0 {
                    <Card className="shadow-sm"><CardContent className="p-10 text-center"><p className="text-lg font-semibold">{ "No matching questions" if query != "" else "It’s quiet around here" }</p><p className="mt-2 text-sm text-muted-foreground">{ "Try another search term or clear your search." if query != "" else "Start the conversation with the first question." }</p></CardContent></Card>
                } else {
                    <div className="flex flex-col gap-3">
                        {for post in visible_posts {
                            <article key={jid(post)} className="group flex overflow-hidden rounded-xl border border-primary/15 bg-card/65 shadow-lg shadow-black/15 backdrop-blur-xl transition-all duration-300 hover:-translate-y-0.5 hover:border-primary/35 hover:shadow-xl hover:shadow-primary/10 animate-in fade-in slide-in-from-bottom-1">
                                <div className="flex w-12 shrink-0 flex-col items-center gap-1 bg-muted/40 py-4 sm:w-14">
                                    {if signed_in { <button aria-label="Upvote" onClick={lambda { handle_vote(jid(post), 1); }} className="rounded p-1 text-muted-foreground transition-colors hover:bg-primary/10 hover:text-primary">▲</button> }}
                                    <span className="text-xs font-bold tabular-nums">{post.votes}</span>
                                    {if signed_in { <button aria-label="Downvote" onClick={lambda { handle_vote(jid(post), -1); }} className="rounded p-1 text-muted-foreground transition-colors hover:bg-primary/10 hover:text-primary">▼</button> }}
                                </div>
                                <div className="min-w-0 flex-1 p-4 sm:p-5">
                                    <div className="mb-2 flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-muted-foreground">
                                        <span className="font-semibold text-foreground">Q/{post.community}</span><span>·</span><span>Asked by {post.author}</span><span>{post.age}</span>
                                    </div>
                                    <h2 className="text-lg font-semibold leading-snug tracking-tight">{post.title}</h2>
                                    <p className="mt-2 line-clamp-3 text-sm leading-relaxed text-muted-foreground">{post.body}</p>
                                    <AnswerThread post_id={jid(post)} signed_in={signed_in} />
                                    <Button variant="ghost" size="sm" className="mt-2 w-fit rounded-full text-xs text-muted-foreground">Share</Button>
                                </div>
                            </article>
                        }}
                    </div>
                }}
            </main>
            <aside className="hidden lg:block">
                <div className="sticky top-24 flex flex-col gap-4">
                    <Card className="border border-primary/15 bg-card/70 shadow-lg shadow-primary/5 backdrop-blur-xl transition-all duration-300 hover:border-primary/30 hover:shadow-xl">
                        <CardContent className="p-4">
                            <div className="mb-3 flex size-10 items-center justify-center rounded-xl bg-primary text-lg font-bold text-primary-foreground shadow-lg shadow-primary/25">Q</div>
                            <h2 className="font-semibold">Home</h2>
                            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">Explore useful answers, share what you know, and help others learn.</p>
                            <Link to="/account"><Button className="mt-4 w-full rounded-full">Join Q&amp;A Finder</Button></Link>
                        </CardContent>
                    </Card>
                    <div className="rounded-xl border bg-card p-4 text-xs leading-relaxed text-muted-foreground shadow-sm">About · Careers · Press · Terms · Privacy<br /><span className="mt-2 inline-block">ANS, Inc. © 2025</span></div>
                </div>
            </aside>
        </div>
    </div>;
}
