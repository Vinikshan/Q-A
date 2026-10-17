import from services.communityService { CommunityPost, get_posts, create_post, vote_post }

# Account creation and login use Jac Scale's built-in /user/register and /user/login endpoints.
# Never trust client-provided admin role/email fields; admin management belongs to Scale's protected portal.

import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }
import from .components.CommunityFeed { CommunityFeed }
import from .components.AccountAccess { AccountAccess }
import from .components.AdminAccounts { AdminAccounts }

def:pub app() -> JsxElement {
    return <Router>
        <Routes>
            <Route path="/" element={<CommunityFeed />} />
            <Route path="/account" element={<AccountAccess />} />
            <Route path="/admin/accounts" element={<AdminAccounts />} />
        </Routes>
    </Router>;
}
