import from .ui.button { Button }
import from .ui.textarea { Textarea }
import from "@jac/runtime" { Link }
sv import from ..services.communityService { CommunityAnswer, get_answers, create_answer }

def:pub AnswerThread(post_id: str, signed_in: bool) -> JsxElement {
    has answers: list[CommunityAnswer] = [];
    has draft: str = "";
    has error: str = "";

    async can with entry {
        try {
            answers = await get_answers(post_id);
        } except Exception {
            error = "Answers could not be loaded.";
        }
    }

    def handle_draft(e: ChangeEvent) { draft = e.target.value; }

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
            <div key={jid(answer)} className="rounded-lg bg-muted/50 p-3"><p className="text-xs font-medium text-primary">{answer.author} <span className="font-normal text-muted-foreground">· {answer.age}</span></p><p className="mt-1 text-sm leading-relaxed">{answer.body}</p></div>
        }}
        {if signed_in {
            <form onSubmit={handle_answer} className="flex flex-col gap-2"><Textarea value={draft} onChange={handle_draft} placeholder="Write a helpful answer" aria-label="Write an answer" className="min-h-16 resize-y" /><Button type="submit" size="sm" className="w-fit rounded-full">Post answer</Button></form>
        } else {
            <p className="text-xs text-muted-foreground"><Link to="/account" className="font-medium text-primary hover:underline">Sign in</Link> to add an answer.</p>
        }}
        {if error != "" { <p role="alert" className="text-xs text-destructive">{error}</p> }}
    </div>;
}
