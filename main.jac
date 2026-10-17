import from services.communityService { CommunityPost, CommunityAnswer, PublicRating, get_posts, get_post, create_post, vote_post, get_answers, create_answer, rate_answer }

import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }
import from .components.CommunityFeed { CommunityFeed }
import from .components.AccountAccess { AccountAccess }
import from .components.AdminAccounts { AdminAccounts }
import from .components.QuestionDetail { QuestionDetail }

def:pub app() -> JsxElement {
    return <Router>
        <Routes>
            <Route path="/" element={<CommunityFeed />} />
            <Route path="/question/:id" element={<QuestionDetail />} />
            <Route path="/account" element={<AccountAccess />} />
            <Route path="/admin/accounts" element={<AdminAccounts />} />
        </Routes>
    </Router>;
}
