import from services.communityService { CommunityPost, get_posts, create_post, vote_post }

import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }
import from .components.CommunityFeed { CommunityFeed }

def:pub app() -> JsxElement {
    return <Router>
        <Routes>
            <Route path="/" element={<CommunityFeed />} />
        </Routes>
    </Router>;
}
