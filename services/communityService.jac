node CommunityPost {
    has title: str = "";
    has body: str = "";
    has community: str = "general";
    has author: str = "Community member";
    has votes: int = 1;
    has comments: int = 0;
    has age: str = "just now";
}

node CommunityAnswer {
    has post_id: str = "";
    has body: str = "";
    has author: str = "Community member";
    has age: str = "just now";
}

def:pub get_posts() -> list[CommunityPost] {
    posts = [root.shared -->][?:CommunityPost];
    if len(posts) == 0 {
        root.shared ++> CommunityPost(title="What small thing made your day better today?", body="A stranger held the door and we both ended up laughing about the rain. It was a tiny moment, but it turned the whole afternoon around.", community="casualconversation", author="kindred_spirit", votes=2841, comments=316, age="2 hr. ago");
        root.shared ++> CommunityPost(title="I finally finished my first mechanical keyboard build", body="After months of reading and collecting parts, the last switch is in. The sound is exactly what I hoped for.", community="MechanicalKeyboards", author="keycap_collector", votes=1204, comments=87, age="4 hr. ago");
        root.shared ++> CommunityPost(title="What are you reading this week?", body="Looking for something absorbing for a long train ride. Fiction, essays, anything you couldn't put down.", community="books", author="paperandtea", votes=632, comments=204, age="6 hr. ago");
        posts = [root.shared -->][?:CommunityPost];
    }
    return posts;
}

def:priv create_post(title: str, body: str, community: str) -> CommunityPost | None {
    if len(title.strip()) == 0 or len(body.strip()) == 0 or len(title) > 180 or len(body) > 5000 or len(community.strip()) == 0 {
        return None;
    }
    return root.shared ++> CommunityPost(title=title.strip(), body=body.strip(), community=community.strip(), author="Community member", votes=1, comments=0, age="just now");
}

def:priv vote_post(post_id: str, direction: int) -> CommunityPost | None {
    if direction != 1 and direction != -1 { return None; }
    for post in [root.shared -->][?:CommunityPost] {
        if jid(post) == post_id {
            post.votes = post.votes + direction;
            return post;
        }
    }
    return None;
}

def:pub get_answers(post_id: str) -> list[CommunityAnswer] {
    return [answer for answer in [root.shared -->][?:CommunityAnswer] if answer.post_id == post_id];
}

def:protect create_answer(post_id: str, body: str) -> CommunityAnswer | None {
    if len(body.strip()) == 0 or len(body) > 5000 { return None; }
    found = False;
    for post in [root.shared -->][?:CommunityPost] {
        if jid(post) == post_id { found = True; }
    }
    if not found { return None; }
    answer = root.shared ++> CommunityAnswer(post_id=post_id, body=body.strip(), author="Community member", age="just now");
    return answer;
}
