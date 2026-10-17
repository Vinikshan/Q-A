import from .ui.card { Card, CardContent }
import from .ui.button { Button }
import from "@jac/runtime" { jacIsLoggedIn, Link }

def:pub AdminAccounts() -> JsxElement {
    return <div className="min-h-screen bg-background text-foreground">
        <header className="border-b bg-card">
            <div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-5">
                <Link to="/" className="flex items-center gap-3"><span className="flex size-9 items-center justify-center rounded-xl bg-primary text-lg font-bold text-primary-foreground">Q</span><span className="text-lg font-bold tracking-tight text-primary">Q&amp;A Finder</span></Link>
                <Link to="/"><Button variant="outline" size="sm">Back to questions</Button></Link>
            </div>
        </header>
        {if not jacIsLoggedIn() {
            <main className="mx-auto flex max-w-2xl flex-col gap-5 px-5 py-12">
                <h1 className="text-3xl font-semibold tracking-tight">Admin account directory</h1>
                <Card className="shadow-sm"><CardContent className="p-6"><h2 className="font-semibold">Sign in required</h2><p className="mt-2 text-sm text-muted-foreground">The account directory is available only to the provisioned site administrator.</p><Link to="/account"><Button className="mt-4">Sign in</Button></Link></CardContent></Card>
            </main>
        } else {
            <main className="mx-auto flex max-w-2xl flex-col gap-5 px-5 py-12">
                <div><h1 className="text-3xl font-semibold tracking-tight">Account administration</h1><p className="mt-2 text-sm text-muted-foreground">Manage registered accounts for your Q&amp;A Finder deployment.</p></div>
                <Card className="shadow-sm"><CardContent className="flex flex-col gap-4 p-6"><div className="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-xl font-bold text-primary">Q</div><h2 className="text-lg font-semibold">Owner-provisioned admin access</h2><p className="text-sm leading-relaxed text-muted-foreground">Account registration never grants administrator privileges. The site owner must provision exactly one administrator through Jac Scale’s protected admin portal. The platform-managed portal is the trusted source for roles and the full account directory; this app does not expose account data to regular users.</p><a href="/admin" className="inline-flex w-fit items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground">Open platform admin portal</a><p className="text-xs leading-relaxed text-muted-foreground">If you are not the provisioned administrator, this portal will deny access. Do not share administrator credentials.</p></CardContent></Card>
            </main>
        }}</div>;
}
