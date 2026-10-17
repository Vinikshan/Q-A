import from .ui.button { Button }
import from .ui.textarea { Textarea }
import from "@jac/runtime" { Link }
sv import from ..services.communityService { CommunityAnswer, get_answers, create_answer, rate_answer }

def:pub AnswerThread(post_id: str, signed_in: bool) -> JsxElement {
    has answers: list[CommunityAnswer] = [];
    has draft: str = "";
    has error: str = "";
    voter_key = localStorage.getItem("qa-finder-rater") or "";

    async can with entry {
        try {
            answers = await get_answers(post_id);
        } except Exception {
            error = "Answers could not be loaded.";
        }
    }

    def handle_draft(e: ChangeEvent) { draft = e.target.value; }

    async def handle_rating(answer_id: str, stars: int) {
        if len(voter_key) < 16 {
            voter_key = str(new(Date).getTime()) + "-" + str(Math.random()) + "-qa-rating-key";
            localStorage.setItem("qa-finder-rater", voter_key);
        }
        try {
            updated = await rate_answer(answer_id, stars, voter_key);
            if updated is not None { answers = [updated if jid(answer) == answer_id else answer for answer in answers]; }
        } except Exception {
            error = "Your answer rating could not be saved.";
        }
    }

    async def handle_answer(e: FormEvent) {
        e.preventDefault();
        if len(draft.strip()) == 0 {
            error = "Write an answer before posting.";
            return;
        }
        error = "";
        try {
            created = await create_answer(post_id, draft);
            if created is None {
                error = "That answer could not be posted. Check the text and try again.";
                return;
            }
            answers = answers + [created];
            draft = "";
        } except Exception {
            error = "Your answer could not be posted. Please sign in and try again.";
        }
    }

    return <div className="mt-4 flex flex-col gap-3 border-t pt-3">
        <p className="text-sm font-semibold">Answers ({str(len(answers))})</p>
        {for answer in answers {
            <div id={"answer-" + jid(answer)} key={jid(answer)} className="rounded-lg border border-primary/10 bg-muted/45 p-3 backdrop-blur-sm"><p className="text-xs font-medium text-primary">{answer.author} <span className="font-normal text-muted-foreground">· {answer.age}</span></p><p className="mt-1 text-sm leading-relaxed">{answer.body}</p><a href={"/question/" + post_id + "#answer-" + jid(answer)} className="mt-2 inline-block text-xs font-medium text-primary hover:underline">Share answer</a><div className="mt-2 flex items-center gap-2"><span className="text-xs text-muted-foreground">{str(round(answer.rating_total / answer.rating_count, 1)) if answer.rating_count > 0 else "Not rated"}</span><span className="text-xs text-muted-foreground">({str(answer.rating_count)})</span><div className="flex items-center">{for star in [1, 2, 3, 4, 5] { <button key={str(star)} type="button" aria-label={"Rate answer " + str(star) + " stars"} onClick={lambda { handle_rating(jid(answer), star); }} className="rounded px-0.5 text-base leading-none text-primary transition-transform duration-150 hover:scale-125">★</button> }}</div></div></div>
        }}
        {if signed_in {
            <form onSubmit={handle_answer} className="flex flex-col gap-2"><Textarea value={draft} onChange={handle_draft} placeholder="Write a helpful answer" aria-label="Write an answer" className="min-h-16 resize-y" /><Button type="submit" size="sm" className="w-fit rounded-full">Post answer</Button></form>
        } else {
            <p className="text-xs text-muted-foreground"><Link to="/account" className="font-medium text-primary hover:underline">Sign in</Link> to add an answer.</p>
        }}
        {if error != "" { <p role="alert" className="text-xs text-destructive">{error}</p> }}
    </div>;
}
