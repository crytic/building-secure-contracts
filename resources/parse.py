#!/usr/bin/env python


from datetime import datetime
from collections import OrderedDict
import toml


categories = OrderedDict([
    ("general", "Security research, analyses, guidances, and writeups"),
    ("tooling", "Description of our tools and their use cases"),
    ("upgradeability", "Our work related to contracts upgradeability"),
    ("consensus algorithms", "Research in the distributes systems area"),
    ("announcements", "Notes of something we did or are planning to do"),
    ("presentations", "Talks, videos, and slides"),
    ("zkp", "Our work in Zero-Knowledge Proofs space"),
    ("fuzzing compilers", "Our work in the topic of fuzzing the `solc` compiler")
])


imgs = {
    "slither": "https://raw.githubusercontent.com/crytic/slither/master/logo.png",
    "echidna": "https://raw.githubusercontent.com/crytic/echidna/master/echidna.png",
    "manticore": "https://raw.githubusercontent.com/trailofbits/manticore/master/docs/images/manticore.png",
    "rattle": "https://raw.githubusercontent.com/crytic/rattle/master/logo_s.png"
}

with open('list.toml', 'r') as f:
    data = toml.load(f)

with open('zkp_list.toml', 'r') as f:
    data.update(toml.load(f))

print(f"{len(data)} blogposts")
print("")

for category in categories.items():
    print(f"## {category[0].capitalize()}\n")
    print(f"{category[1]}\n")

    blogpost_for_category = []
    for blogpost_title in list(data.keys()):
        if category[0] not in data[blogpost_title]['category']:
            continue

        blogpost = data.pop(blogpost_title)
        blogpost_for_category.append((blogpost_title, blogpost))

    if category[0] == "tooling":
        print("| Date |  Tool | Title | Description |")
        print( ("|" + "-"*5)*4 + "|")
    else:
        print("| Date | Title | Description |")
        print( ("|" + "-"*5)*3 + "|")

    for blogpost_title, blogpost in sorted(blogpost_for_category, key=lambda x: datetime.strptime(x[1]['date'], '%Y/%m/%d'), reverse=True):
        # print(f"* [{blogpost_title}]({blogpost['link']}). {blogpost['description']}" + "." if blogpost['description'] else "")

        if category[0] == "tooling":
            img_str = ""
            for category_tool_name, category_tool_link in imgs.items():
                if category_tool_name in blogpost['category']:
                    img_str = f"<img src='{category_tool_link}' alt='{category_tool_name}' width=100px />"
                    break

            print(f"| {blogpost['date']} | {img_str} | [{blogpost_title}]({blogpost['link']}) | {blogpost['description']} |")
        else:
            print(f"| {blogpost['date']} | [{blogpost_title}]({blogpost['link']}) | {blogpost['description']} |")
    print("")

if data:
    print("Remains:")
    print(data)