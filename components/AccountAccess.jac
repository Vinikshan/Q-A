import from .ui.button { Button }
import from .ui.card { Card, CardContent }
import from .ui.input { Input }
import from "@jac/runtime" { jacLogin, jacSignup, useNavigate, Link }


def:pub AccountAccess() -> JsxElement {
    has email: str = "";
    has password: str = "";
    has password_confirm: str = "";
    has mode: str = "register";
    has message: str = "";
    has busy: bool = False;
    nav = useNavigate();

    def handle_email(e: ChangeEvent) { email = e.target.value; }
    def handle_password(e: ChangeEvent) { password = e.target.value; }
    def handle_password_confirm(e: ChangeEvent) { password_confirm = e.target.value; }
    def handle_mode(e: MouseEvent) {
        mode = "login" if mode == "register" else "register";
        message = "";
        password_confirm = "";
    }
    def handle_forgot(e: MouseEvent) { mode = "forgot"; message = ""; }
    def handle_back_to_login(e: MouseEvent) { mode = "login"; message = ""; }

    async def handle_submit(e: FormEvent) {
        e.preventDefault();
        message = "";
        if len(email.strip()) == 0 {
            message = "Enter your email address.";
            return;
        }
        if mode == "forgot" {
            message = "Password recovery email is unavailable until the site owner configures an email provider.";
            return;
        }
        if mode == "register" {
            has_upper = False;
            has_lower = False;
            has_digit = False;
            has_symbol = False;
            for ch in password {
                if ch.isupper() { has_upper = True; }
                if ch.islower() { has_lower = True; }
                if ch.isdigit() { has_digit = True; }
                if not ch.isalnum() { has_symbol = True; }
            }
            if len(password) < 8 or not has_upper or not has_lower or not has_digit or not has_symbol {
                message = "Use at least 8 characters with an uppercase letter, lowercase letter, number, and symbol.";
                return;
            }
            if password != password_confirm {
                message = "The passwords do not match.";
                return;
            }
        } elif len(password) == 0 {
            message = "Enter your password.";
            return;
        }
        busy = True;
        if mode == "register" {
            result: dict | None = None;
            ok: bool = False;
            try {
                result = await jacSignup(email.strip(), password);
                if not result["success"] {
                    message = "That email could not be registered. It may already be in use.";
                    busy = False;
                    return;
                }
                ok = await jacLogin(email.strip(), password);
                if ok {
                    nav("/");
                } else {
                    message = "Account created. Sign in to continue.";
                    mode = "login";
                }
            } except Exception {
                message = "Account creation failed. Check the details and try again.";
            }
        } else {
            ok: bool = False;
            try {
                ok = await jacLogin(email.strip(), password);
                if ok {
                    nav("/");
                } else {
                    message = "Those sign-in details were not accepted.";
                }
            } except Exception {
                message = "Sign in failed. Check your email and password.";
            }
        }
        busy = False;
    }

    return <div className="grid min-h-screen bg-background lg:grid-cols-2">
        <section className="relative hidden flex-col justify-between overflow-hidden bg-primary p-10 text-primary-foreground lg:flex">
            <div className="absolute -right-24 -top-24 size-96 rounded-full bg-primary-foreground/10 blur-3xl" />
            <Link to="/" className="relative flex items-center gap-3">
                <span className="flex size-10 items-center justify-center rounded-xl bg-primary-foreground/15 text-xl font-bold">Q</span>
                <span className="text-xl font-bold tracking-tight">Q&amp;A Finder</span>
            </Link>
            <div className="relative max-w-lg">
                <p className="mb-4 text-sm font-medium text-primary-foreground/75">A better place to ask</p>
                <h1 className="text-balance text-5xl font-semibold leading-tight tracking-tight">Good questions find good answers.</h1>
                <p className="mt-5 max-w-md text-base leading-relaxed text-primary-foreground/80">Join thoughtful conversations, share what you know, and learn from the communities you care about.</p>
            </div>
            <p className="relative text-sm text-primary-foreground/70">A community built around curiosity.</p>
        </section>
        <section className="flex min-h-screen flex-col bg-background px-6 py-8 sm:px-10">
            <Link to="/" className="flex items-center gap-2 font-semibold text-primary lg:hidden"><span className="flex size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">Q</span> Q&amp;A Finder</Link>
            <div className="flex flex-1 items-center justify-center py-10">
                <form onSubmit={handle_submit} className="flex w-full max-w-sm flex-col gap-6 rounded-2xl border border-border/70 bg-card/60 p-6 shadow-2xl shadow-primary/5 backdrop-blur-xl animate-in fade-in slide-in-from-bottom-2 duration-500 sm:p-8">
                    <div className="flex flex-col gap-2">
                        <h2 className="text-3xl font-semibold tracking-tight">{"Create your account" if mode == "register" else "Reset your password" if mode == "forgot" else "Welcome back"}</h2>
                        <p className="text-sm text-muted-foreground">{"Use your email to join Q&A Finder." if mode == "register" else "Enter your account email for recovery instructions." if mode == "forgot" else "Sign in to continue the conversation."}</p>
                    </div>
                    <div className="flex flex-col gap-4">
                        <label className="flex flex-col gap-2 text-sm font-medium" htmlFor="account-email">Email address
                            <Input id="account-email" type="email" autoComplete="email" placeholder="you@example.com" value={email} onChange={handle_email} required={True} />
                        </label>
                        {if mode != "forgot" {
                            <label className="flex flex-col gap-2 text-sm font-medium" htmlFor="account-password">Password
                                <Input id="account-password" type="password" autoComplete={"new-password" if mode == "register" else "current-password"} placeholder={"8+ characters, upper/lowercase, number, symbol" if mode == "register" else "Your password"} value={password} onChange={handle_password} required={True} minLength={8} />
                            </label>
                        }}
                        {if mode == "register" {
                            <label className="flex flex-col gap-2 text-sm font-medium" htmlFor="account-password-confirm">Confirm password
                                <Input id="account-password-confirm" type="password" autoComplete="new-password" placeholder="Re-enter your password" value={password_confirm} onChange={handle_password_confirm} required={True} minLength={8} />
                            </label>
                        }}
                    </div>
                    {if message != "" { <p role="alert" className="rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm text-destructive">{message}</p> }}
                    <Button type="submit" disabled={busy} className="h-11 w-full">{"Creating account..." if busy and mode == "register" else "Signing in..." if busy and mode == "login" else "Send recovery instructions" if mode == "forgot" else "Create account" if mode == "register" else "Sign in"}</Button>
                    {if mode == "login" {
                        <button type="button" onClick={handle_forgot} className="self-center text-sm font-medium text-primary underline-offset-4 hover:underline">Forgot password?</button>
                    }}
                    <p className="text-center text-sm text-muted-foreground">
                        {"Already have an account? " if mode == "register" else "Remembered your password? " if mode == "forgot" else "New to Q&A Finder? "}
                        <button type="button" onClick={handle_back_to_login if mode == "forgot" else handle_mode} className="font-semibold text-primary underline-offset-4 hover:underline">{"Sign in" if mode == "register" or mode == "forgot" else "Create an account"}</button>
                    </p>
                    {if mode == "register" { <p className="text-center text-xs leading-relaxed text-muted-foreground">Signup passwords must include uppercase and lowercase letters, a number, and a symbol. Email verification will be available after the site owner configures a mail provider. Admin access is provisioned separately.</p> }}
                </form>
            </div>
        </section>
    </div>;
}
