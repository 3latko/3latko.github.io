/**
 *  Publish
 *  Copyright (c) John Sundell 2019
 *  MIT license, see LICENSE file for details
 */

import Plot
import Publish

public extension Theme {
  /// The default "Foundation" theme that Publish ships with, a very
  /// basic theme mostly implemented for demonstration purposes.
  static var kodium: Self {
    Theme(
      htmlFactory: FoundationHTMLFactory(),
      resourcePaths: ["Resources/KodiumTheme/styles.css"]
    )
  }
}

private struct FoundationHTMLFactory<Site: Website>: HTMLFactory {
  func makeIndexHTML(for index: Index,
                     context: PublishingContext<Site>) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: index, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: nil)
        Wrapper {
          H1(index.title)
          Paragraph(context.site.description)
            .class("description")
          
          H2("Introduction")
          Paragraph(
          """
          Welcome to Kodium, where innovation meets mobility! We're a dynamic mobile app development company committed to crafting outstanding digital experiences. Our goal is to empower clients with cutting-edge mobile solutions that captivate users worldwide.
          """).class("description")
          
          Paragraph(
          """
          Kodium specializes in creating visually stunning and highly functional mobile apps. Our team's expertise spans various platforms, ensuring your app reaches a broad audience. We prioritize user-centric design, utilize the latest technology, and offer end-to-end services, making us your trusted partner for mobile success. Join us in shaping the future of mobile technology with Kodium!
          """).class("description")
          
          H2("Contact")
          Paragraph {
            Text("Write us at ")
            Link("kodium.mk@gmail.com", url: "mailto:kodium.mk@gmail.com")
          }
          //                    H2("Latest content")
          //                    ItemList(
          //                        items: context.allItems(
          //                            sortedBy: \.date,
          //                            order: .descending
          //                        ),
          //                        site: context.site
          //                    )
        }
//        SiteFooter()
      }
    )
  }
  
  func makeSectionHTML(for section: Section<Site>,
                       context: PublishingContext<Site>) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: section, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: section.id)
        Wrapper {
          H1(section.title)
          ItemList(items: section.items, site: context.site)
        }
        SiteFooter()
      }
    )
  }
  
  func makeItemHTML(for item: Item<Site>,
                    context: PublishingContext<Site>) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: item, on: context.site),
      .body(
        .class("item-page"),
        .components {
          SiteHeader(context: context, selectedSelectionID: item.sectionID)
          Wrapper {
            Article {
              Div(item.content.body).class("content")
              Span("Tagged with: ")
              ItemTagList(item: item, site: context.site)
            }
          }
          SiteFooter()
        }
      )
    )
  }
  
  func makePageHTML(for page: Page,
                    context: PublishingContext<Site>) throws -> HTML {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: nil)
        Wrapper(page.body)
        SiteFooter()
      }
    )
  }
  
  func makeTagListHTML(for page: TagListPage,
                       context: PublishingContext<Site>) throws -> HTML? {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: nil)
        Wrapper {
          H1("Browse all tags")
          List(page.tags.sorted()) { tag in
            ListItem {
              Link(tag.string,
                   url: context.site.path(for: tag).absoluteString
              )
            }
            .class("tag")
          }
          .class("all-tags")
        }
        SiteFooter()
      }
    )
  }
  
  func makeTagDetailsHTML(for page: TagDetailsPage,
                          context: PublishingContext<Site>) throws -> HTML? {
    HTML(
      .lang(context.site.language),
      .head(for: page, on: context.site),
      .body {
        SiteHeader(context: context, selectedSelectionID: nil)
        Wrapper {
          H1 {
            Text("Tagged with ")
            Span(page.tag.string).class("tag")
          }
          
          Link("Browse all tags",
               url: context.site.tagListPath.absoluteString
          )
          .class("browse-all")
          
          ItemList(
            items: context.items(
              taggedWith: page.tag,
              sortedBy: \.date,
              order: .descending
            ),
            site: context.site
          )
        }
        SiteFooter()
      }
    )
  }
}

private struct Wrapper: ComponentContainer {
  @ComponentBuilder var content: ContentProvider
  
  var body: Component {
    Div(content: content).class("wrapper")
  }
}

private struct SiteHeader<Site: Website>: Component {
  var context: PublishingContext<Site>
  var selectedSelectionID: Site.SectionID?
  
  var body: Component {
    Header {
      Wrapper {
        Link(context.site.name, url: "/")
          .class("site-name")
        
        if Site.SectionID.allCases.count > 1 {
          navigation
        }
      }
    }
  }
  
  private var navigation: Component {
    Navigation {
      List(Site.SectionID.allCases) { sectionID in
        let section = context.sections[sectionID]
        
        return Link(section.title,
                    url: section.path.absoluteString
        )
        .class(sectionID == selectedSelectionID ? "selected" : "")
      }
    }
  }
}

private struct ItemList<Site: Website>: Component {
  var items: [Item<Site>]
  var site: Site
  
  var body: Component {
    List(items) { item in
      Article {
        H1(Link(item.title, url: item.path.absoluteString))
        ItemTagList(item: item, site: site)
        Paragraph(item.description)
      }
    }
    .class("item-list")
  }
}

private struct ItemTagList<Site: Website>: Component {
  var item: Item<Site>
  var site: Site
  
  var body: Component {
    List(item.tags) { tag in
      Link(tag.string, url: site.path(for: tag).absoluteString)
    }
    .class("tag-list")
  }
}

private struct SiteFooter: Component {
  var body: Component {
    Footer {
      Paragraph {
        Text("Generated using ")
        Link("Publish", url: "https://github.com/johnsundell/publish")
      }
      Paragraph {
        Link("RSS feed", url: "/feed.rss")
      }
    }
  }
}
