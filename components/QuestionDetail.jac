import from .ui.button { Button }
import from .ui.card { Card, CardContent }
import from "@jac/runtime" { Link, useParams }
sv import from ..services.communityService { CommunityPost, CommunityAnswer, get_post, get_answers }

def:pub QuestionDetail() -> JsxElement {
    has question: CommunityPost | None = None;
    has answers: list[CommunityAnswer] = [];
    has loading: bool = True;
    has error: str = "";
    params = useParams();
    question_id = params["id"] as str;

    async can with entry {
        if question_id {
            try {
                question = await get_post(question_id);
                if question is None {
                    error = "This question could not be found.";
                } else {
                    answers = await get_answers(question_id);
                }
            } except Exception {
                error = "This question could not be loaded.";
            }
        } else {
            error = "This question could not be found.";
        }
        loading = False;
    }

    return <div className="min-h-screen bg-background text-foreground">
        <header className="sticky top-0 z-20 border-b border-primary/15 bg-background/65 backdrop-blur-2xl">
            <div className="mx-auto flex h-16 max-w-4xl items-center justify-between px-4 sm:px-6">
                <Link to="/" className="flex items-center gap-3"><span className="flex size-9 items-center justify-center rounded-xl bg-primary font-bold text-primary-foreground shadow-lg shadow-primary/30">Q</span><span className="font-bold text-primary">Q&amp;A Finder</span></Link>
                <Link to="/"><Button variant="outline" size="sm">Back to questions</Button></Link>
            </div>
        </header>
        <main className="mx-auto flex w-full max-w-4xl flex-col gap-5 px-4 py-8 sm:px-6">
            {if loading {
                <Card className="border-primary/15 bg-card/65 shadow-xl backdrop-blur-xl"><CardContent className="p-8"><div className="h-5 w-2/3 animate-pulse rounded bg-muted" /><div className="mt-4 h-16 animate-pulse rounded bg-muted" /></CardContent></Card>
            } elif question is None {
                <Card className="border-primary/15 bg-card/65 shadow-xl backdrop-blur-xl"><CardContent className="p-8"><h1 className="text-xl font-semibold">Question unavailable</h1><p className="mt-2 text-sm text-muted-foreground">{error}</p><Link to="/"><Button className="mt-4">Return to Q&amp;A Finder</Button></Link></CardContent></Card>
            } else {
                <article className="rounded-2xl border border-primary/20 bg-card/70 p-6 shadow-xl shadow-primary/5 backdrop-blur-xl sm:p-8">
                    <p className="text-sm font-medium text-primary">Q/{question.community} <span className="text-muted-foreground">· Asked by {question.author} · {question.age}</span></p>
                    <h1 className="mt-3 text-2xl font-semibold tracking-tight sm:text-3xl">{question.title}</h1>
                    <p className="mt-4 whitespace-pre-wrap leading-relaxed text-muted-foreground">{question.body}</p>
                    <section className="mt-6 flex flex-col gap-3 border-t border-primary/15 pt-4">
                        <h2 className="font-semibold">Answers ({str(len(answers))})</h2>
                        {for answer in answers {
                            <div id={"answer-" + jid(answer)} key={jid(answer)} className="rounded-xl border border-primary/10 bg-muted/45 p-4">
                                <p className="text-xs font-medium text-primary">{answer.author} <span className="font-normal text-muted-foreground">· {answer.age}</span></p>
                                <p className="mt-2 whitespace-pre-wrap text-sm leading-relaxed">{answer.body}</p>
                                <p className="mt-2 text-xs text-muted-foreground">{str(round(answer.rating_total / answer.rating_count, 1)) if answer.rating_count > 0 else "Not rated"} · {str(answer.rating_count)} ratings</p>
                            </div>
                        }}
                    </section>
                </article>
            }}
        </main>
    </div>;
}
