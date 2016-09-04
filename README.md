### Fangirls
Fangirls is a super-simple front-end to the [**youtube-dl**](https://github.com/rg3/youtube-dl) project. In short, it grabs the source of videos you watch on the web, and downloads them to your computer. Despite the name, **youtube-dl** supports vastly more services than YouTube — you can [see a full list](http://rg3.github.io/youtube-dl/supportedsites.html). It's also a pretty active project; if there's a site that it doesn't work for, the developers are willing to take requests.

One problem with **youtube-dl** is that it's a Python app that you have to use from the command line. I love the command line as much as any card-carrying nerd, but I wanted to build a quick Mac app, and this seemed like a good opportunity. 

Here's a picture of Fangirls in action:

<img src="https://github.com/aaronvegh/Fangirls/raw/gh-pages/fangirls.png" alt="Fangirls" />

### Features
It's pretty bare-bones at this point. Paste in the URL of a web page that contains a video, and Fangirls will use an included copy of **youtube-dl** to pull the video data from that page and download what it finds. In bullet form, then:

* Download videos from the sites that youtube-dl supports;
* Multiple video-per-page support: it'll show a progress bar for each video it finds;
* Choose your download location
* ...what else do you even need?

### Future Considerations
Yeah, actually there's a _ton_ of features in **youtube-dl** that aren't supported in Fangirls. Here's a list of a few that I'd like to implement:

* Show/pick from a list of available formats. While most videos that come down are in Mac-friendly MP4 format, some strange folks upload _webm_, and that's what you end up with if it's the highest-quality format.
* Provide more of the power of **youtube-dl**. I mean, [just look at all the options](https://github.com/rg3/youtube-dl/blob/master/README.md#options). A lot of it is unnecessary for the vast majority of users, but some configuration could be handy to prevent trips to the command line.
* UI niceties, like storing the videos you've downloaded, showing the original source page, providing Preferences
* A mechanism for updating **youtube-dl** and showing what version it's at. This should really happen in the background.

### Why "Fangirls"?
It's a word my 12-year-old daughter is using a lot these days, both as a noun and (more entertainingly) a verb. It's interchangeably a derogation and word of praise. And it was on my mind when I sat at the New Project dialogue in Xcode the other night.

### Who designed your amazing app icon?
Har, har. It was me.

### License
I'm releasing Fangirls under the [Creative Commons Attribution 4.0 license](https://creativecommons.org/licenses/by/4.0/). In short, you can do whatever you like with this code as long as you give me credit. Which brings me to...

### Contributions
I'd be happy to accept your PRs! Make a fork of this project and shoot me a pull request and let's make Fangirls truly fangirl-worthy.
