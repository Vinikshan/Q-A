node CommunityPost {
    has title: str = "";
    has body: str = "";
    has community: str = "general";
    has author: str = "Community member";
    has votes: int = 1;
    has comments: int = 0;
    has answer_count: int = 0;
    has age: str = "just now";
}

node CommunityAnswer {
    has post_id: str = "";
    has body: str = "";
    has author: str = "Community member";
    has rating_total: int = 0;
    has rating_count: int = 0;
    has age: str = "just now";
}

node PublicRating {
    has target_id: str = "";
    has target_kind: str = "question";
    has voter_key: str = "";
    has stars: int = 0;
}

def:pub get_posts() -> list[CommunityPost] {
    posts = [root.shared -->][?:CommunityPost];
    if len(posts) < 50 {
        seeds: list[list[str]] = [
            ["Everyday", "What tiny habit makes ordinary mornings feel calmer?", "I want a routine that takes under ten minutes and does not start with checking my phone.", "Put a glass of water beside your bed, open a window, and write down the one thing that matters today. Keep it small enough to repeat."],
            ["Learning", "How do you remember what you read in nonfiction?", "I highlight too much and forget most of it a week later. What helps ideas actually stick?", "After each chapter, close the book and write three sentences from memory. Reviewing those notes a few days later helps more than highlighting."],
            ["Technology", "What is a good first project for learning a new programming language?", "Tutorials make sense while I follow them, but I freeze when I start from a blank editor.", "Build a personal reading list with add, complete, and remove actions. It is small enough to finish but teaches input, state, and persistence."],
            ["Books", "How do you choose your next book when your reading list is huge?", "I spend more time picking than reading. Looking for a simple way to decide.", "Pick the book that best fits your current mood, not the one you feel you ought to read. A short sample chapter is a useful tie-breaker."],
            ["Cooking", "What is a reliable weeknight dinner with pantry ingredients?", "I have beans, rice, canned tomatoes, and a few spices. Hoping for something flexible.", "Simmer the beans with tomatoes, cumin, and smoked paprika, then serve over rice. Add lemon or vinegar at the end to brighten it."],
            ["Science", "Why does the moon look larger near the horizon?", "It seems huge when rising, then smaller overhead, even though I know its distance barely changes.", "It is a visual illusion: nearby scenery gives your brain a size comparison at the horizon. Photos with the same zoom show nearly the same apparent size."],
            ["Productivity", "What is your favorite way to restart after an unproductive day?", "I tend to turn one missed task into a whole week of feeling behind.", "Choose one task that takes five minutes, do it, then write the next step for tomorrow. A small restart is more useful than catching up all at once."],
            ["Outdoors", "How do beginners get more comfortable hiking alone?", "I would like to try easy local trails but feel unsure about preparation.", "Start with a short, popular, well-marked route. Share your plan with someone, check the forecast, carry water and a charged phone, and turn back early if needed."],
            ["Design", "How can I make a personal website feel easier to read?", "My page feels crowded even though it does not contain much content.", "Increase line spacing, limit paragraph width, and create more contrast between headings and body text. Remove elements that do not help someone complete a task."],
            ["Home", "What is a quick way to reduce clutter on a desk?", "My workspace collects cables, notes, and objects I rarely use.", "Keep only the items you use daily within reach. Put cables in one labeled pouch and give papers a single inbox instead of several small piles."],
            ["Learning", "How do you practice a language when you only have fifteen minutes?", "I can study briefly each day but cannot fit a full lesson into my schedule.", "Spend five minutes reviewing yesterday's phrases, five listening to a short clip, and five writing or saying a few sentences using what you heard."],
            ["Technology", "What should I back up before replacing a laptop?", "I do not want to discover later that an important folder lived only on the old machine.", "Back up documents, photos, project files, browser bookmarks, and password-manager recovery details. Open a few files from the backup to confirm it works."],
            ["Wellbeing", "What helps you remember to take screen breaks?", "I often notice eye strain only after I have been focused for hours.", "Tie a short break to an existing cue, like finishing a meeting or saving a document. Look across the room and move around for a minute."],
            ["Photography", "How can I take better photos in cloudy weather?", "Overcast days make my outdoor pictures look flat and gray.", "Look for color, reflections, and texture rather than strong shadows. A nearby subject against a brighter background can create depth on cloudy days."],
            ["Career", "What makes a portfolio project description useful to a hiring team?", "I have projects to show but struggle to explain why they matter.", "State the problem, your specific contribution, one meaningful tradeoff, and what you learned. Screenshots help, but concise context makes them understandable."],
            ["Cooking", "How can I make leftovers feel less repetitive?", "I like batch cooking but get tired of eating the same plate several days in a row.", "Keep the base ingredients plain and change the format: turn roasted vegetables into a wrap, grain bowl, soup, or quick fried rice with a different sauce."],
            ["Books", "What makes a book club discussion welcoming to quieter members?", "Our group sometimes gets dominated by the fastest talkers.", "Send one question ahead of time and let everyone share a short first thought before open discussion. Passing should always be an acceptable option."],
            ["Science", "Why do metal objects feel colder than wooden ones in the same room?", "They have the same temperature, but the metal feels much colder to touch.", "Metal conducts heat away from your skin faster than wood does. Your nerves respond to that faster heat loss, so metal feels colder."],
            ["Everyday", "What is a thoughtful way to thank someone who helped you?", "A colleague went out of their way to make a difficult week easier.", "Be specific about what they did and how it helped. A short sincere message is often more meaningful than a generic gift."],
            ["Technology", "How do you keep personal files organized across devices?", "I have duplicate downloads and cannot remember which copy is current.", "Choose one primary synced folder, use descriptive filenames with dates when useful, and archive old versions instead of keeping multiple ambiguous copies."],
            ["Outdoors", "What should I bring for a first overnight camping trip?", "I have day-hiked before but have not slept outdoors yet.", "Borrow or rent a tent, sleeping bag suited to the forecast, pad, headlamp, water, food, layers, and first-aid basics. Try the gear at home first."],
            ["Productivity", "How do you estimate tasks that always take longer than expected?", "My calendar is full because I plan only the ideal version of each task.", "Track actual time for a week, then use those observations as your baseline. Include setup, review, and interruptions instead of estimating only focused work."],
            ["Design", "What is a quick accessibility check for a web page?", "I want to catch obvious issues before asking someone else to review it.", "Navigate with only a keyboard, zoom the page to 200 percent, check text contrast, and confirm every form control has a clear label."],
            ["Home", "How do you keep houseplants alive during a busy week?", "I either forget to water them or overcorrect and water too much.", "Check the soil before watering rather than following a fixed calendar. Group plants by light and water needs, and use pots with drainage."],
            ["Learning", "What is a good way to prepare for a technical interview without cramming?", "I want to build confidence over a month while keeping evenings manageable.", "Practice a few core patterns regularly, explain your reasoning aloud, and review mistakes. Short spaced sessions usually beat a single long cram."],
            ["Career", "How can I ask for feedback after finishing a project?", "I want actionable input, not only a general 'looks good'.", "Ask one focused question, such as what was hardest to understand or which part should be improved first. Specific prompts produce more useful feedback."],
            ["Cooking", "What is the easiest way to make soup taste more balanced?", "My soups sometimes taste either dull or too salty.", "Adjust in small steps: salt for seasoning, acid like lemon for brightness, and herbs or spices for aroma. Taste after each change."],
            ["Science", "Why do we see lightning before hearing thunder?", "I know it is related to distance, but I am curious about the simple explanation.", "Light travels much faster than sound, so the flash reaches you first. The delay gives a rough sense of how far away the storm is."],
            ["Everyday", "How do you make a new neighbor feel welcome without being intrusive?", "Someone new moved in nearby and I would like to say hello naturally.", "Offer a brief introduction and a practical local tip, then let them decide whether to continue chatting. A friendly, low-pressure invitation works well."],
            ["Technology", "What is a safe way to try a command-line tool I found online?", "I want to experiment without risking files on my main computer.", "Read the source and documentation first, then test in a disposable container or virtual machine with no sensitive folders mounted."],
            ["Books", "How do you get back into reading after a long break?", "I miss reading but find myself reaching for short videos instead.", "Leave an engaging book somewhere visible and read just a few pages at a consistent time. Choosing something easy to enter helps rebuild the habit."],
            ["Outdoors", "What is a simple way to identify local birds as a beginner?", "I recognize a few common birds but do not know where to start.", "Notice size, shape, location, and behavior before color. Keep a small field guide or trusted identification app and record where you saw it."],
            ["Wellbeing", "How can I make a long meeting day less draining?", "I have several video calls in a row and feel depleted by the afternoon.", "When possible, leave short gaps between calls, stand during one meeting, and write down the next action before switching contexts."],
            ["Design", "When should a button use an outline style instead of a solid fill?", "My interface has several actions that all compete for attention.", "Use a solid style for the primary action in a section. Secondary or optional actions can use outline or quiet styles so hierarchy stays clear."],
            ["Home", "What is a useful first step when a room feels difficult to organize?", "I keep moving objects around without making lasting progress.", "Choose one small zone, decide what belongs there, and remove items that belong elsewhere. Finish that area before expanding the project."],
            ["Productivity", "How do you decide which notification settings to turn off?", "My phone interrupts focus but I do not want to miss urgent messages.", "Keep alerts for people or events that truly need a timely response. Batch informational apps into scheduled checks and silence the rest."],
            ["Learning", "What is a practical way to learn from mistakes without dwelling on them?", "I want to improve but can get stuck replaying what went wrong.", "Write down what happened, what was within your control, and one experiment for next time. Then move on once you have a useful action."],
            ["Photography", "How do I keep horizons straight in handheld photos?", "My landscapes often look slightly tilted even when the scene felt level.", "Turn on the camera's grid or level guide and align it with a stable horizon. Cropping a little later can fix small remaining tilts."],
            ["Career", "How should I prepare for a one-to-one with my manager?", "I want to use the time well without turning it into a long status report.", "Bring your top priority, one blocker, and one question about growth or feedback. Share status asynchronously when possible."],
            ["Cooking", "How can I reduce food waste when cooking for one?", "Fresh ingredients often spoil before I use them all.", "Plan two meals around overlapping ingredients, freeze extra portions promptly, and keep a visible list of foods that need using soon."],
            ["Everyday", "What is a helpful way to support a friend who is stressed?", "I want to be there for someone without rushing to solve everything.", "Ask whether they want listening, practical help, or ideas. Reflect what you heard and follow their lead rather than assuming what they need."],
            ["Science", "Why does a spinning top stay upright for a while?", "I am looking for an intuitive explanation of its motion.", "Its rotation gives it angular momentum, which resists changes to its direction. Friction gradually slows it until gravity tips it over."],
            ["Technology", "What details should I include in a useful bug report?", "I want engineers to reproduce an issue without a long back-and-forth.", "Include what you expected, what happened, exact steps, device or browser details, and a screenshot or error text when safe to share."],
            ["Books", "How do you remember characters in a novel with a large cast?", "I enjoy the story but forget who everyone is between reading sessions.", "Keep a tiny note with each character's name and one identifying detail. A few keywords are enough to reconnect without spoiling the story."],
            ["Outdoors", "How do you make a neighborhood walk more interesting?", "I want to move more but do not enjoy repeating the exact same route.", "Choose a theme for each walk, like noticing gardens, architecture, or street art, and take a different side street when it is safe."],
            ["Design", "What makes an empty state helpful in an app?", "Our product has a blank list for new users and it feels confusing.", "Explain what belongs there, why it is useful, and offer one clear first action. Avoid leaving a blank panel with no direction."],
            ["Wellbeing", "How do you remember to stretch during desk work?", "I get focused and realize hours have passed without moving.", "Pair a brief stretch with a regular cue such as finishing a call or refilling water. A little movement done often is easier to sustain."],
            ["Home", "What is a simple way to make a small entryway more practical?", "Shoes, bags, and keys pile up by the door in my apartment.", "Give each daily item a defined landing place: a small tray for keys, hooks for bags, and a washable mat or shoe rack."],
            ["Productivity", "How do you protect time for deep work on a busy calendar?", "Short meetings break up the day and leave little room for focused tasks.", "Block a realistic recurring window, tell collaborators when you are available, and move small administrative tasks into a separate batch."],
            ["Everyday", "What is one low-cost way to celebrate a personal milestone?", "I finished something important and want to mark it without planning a big event.", "Share a meal with someone you care about, take a photo, or write down what you learned. A deliberate pause can make the moment feel special."],
            ["Technology", "How can I make a long password easier to manage safely?", "I know reused passwords are risky, but remembering unique ones is difficult.", "Use a reputable password manager to generate and store a unique password for each account, and protect it with a strong master password."],
        ];
        for (index, seed) in enumerate(seeds) {
            post = root.shared ++> CommunityPost(title=seed[1], body=seed[2], community=seed[0], author="Q&A Finder community", votes=1 + (len(seeds) - index) * 3, comments=0, age="Community pick");
            root.shared ++> CommunityAnswer(post_id=jid(post), body=seed[3], author="Q&A Finder contributor", age="Community answer");
            post.answer_count = 1;
        }
        posts = [root.shared -->][?:CommunityPost];
    }
    for post in posts {
        post.answer_count = len([answer for answer in [root.shared -->][?:CommunityAnswer] if answer.post_id == jid(post)]);
    }
    return posts;
}

def:pub get_post(post_id: str) -> CommunityPost | None {
    for post in [root.shared -->][?:CommunityPost] {
        if jid(post) == post_id { return post; }
    }
    return None;
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
    post: CommunityPost | None = None;
    for candidate in [root.shared -->][?:CommunityPost] {
        if jid(candidate) == post_id { post = candidate; }
    }
    if post is None { return None; }
    if isinstance(post, CommunityPost) {
        answer = root.shared ++> CommunityAnswer(post_id=post_id, body=body.strip(), author="Community member", age="just now");
        post.answer_count = post.answer_count + 1;
        return answer;
    }
    return None;
}

# Public ratings are open to visitors; browser token limits repeated votes per target.
def:pub rate_answer(answer_id: str, stars: int, voter_key: str) -> CommunityAnswer | None {
    if stars < 1 or stars > 5 or len(voter_key) < 16 or len(voter_key) > 100 { return None; }
    for answer in [root.shared -->][?:CommunityAnswer] {
        if jid(answer) == answer_id {
            existing: PublicRating | None = None;
            for rating in [root.shared -->][?:PublicRating] {
                if rating.target_kind == "answer" and rating.target_id == answer_id and rating.voter_key == voter_key { existing = rating; }
            }
            if existing is None {
                root.shared ++> PublicRating(target_id=answer_id, target_kind="answer", voter_key=voter_key, stars=stars);
                answer.rating_total = answer.rating_total + stars;
                answer.rating_count = answer.rating_count + 1;
            } elif isinstance(existing, PublicRating) {
                answer.rating_total = answer.rating_total - existing.stars + stars;
                existing.stars = stars;
            }
            return answer;
        }
    }
    return None;
}
