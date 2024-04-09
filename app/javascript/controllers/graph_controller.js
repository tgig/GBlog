import { Controller } from "@hotwired/stimulus"
import "d3"

export default class extends Controller {
  static targets = ["graphContainer"]
  static values = { folderId: String, titleId: String }

  connect() {
    this.fetchAndRenderGraphData()
  }

  async fetchAndRenderGraphData() {
    try {
      const data = await this.fetchGraphData(
        this.folderIdValue,
        this.titleIdValue
      )
      this.createGraph(data)
    } catch (error) {
      this.handleError(error)
    }
  }

  async fetchGraphData(folderId, titleId) {
    const response = await fetch(`/${folderId}/${titleId}/graph`)
    if (!response.ok) {
      throw new Error("Network response was not ok")
    }
    return response.json()
  }

  createGraph(data) {
    const width = document.body.clientWidth,
      height = this.sumOfPageRanks(data.pages),
      svg = d3
        .select(this.graphContainerTarget)
        .append("svg")
        .attr("width", width)
        .attr("height", height)

    const nodes = data.pages.map((d) => Object.create(d))
    const links = data.links.map((d) => Object.create(d))

    const simulation = d3
      .forceSimulation()
      .force("charge", d3.forceManyBody().strength(-50))
      .force(
        "link",
        d3.forceLink().id((d) => d.id)
      )
      .force(
        "collision",
        d3.forceCollide().radius((d) => d.page_rank + 4)
      )
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("x", d3.forceX(width / 2).strength(0.1))
      .force("y", d3.forceY(height / 2).strength(0.3))

    // Update nodes and links on each tick
    simulation.nodes(nodes).on("tick", () => {
      link
        .attr("x1", (d) => d.source.x)
        .attr("y1", (d) => d.source.y)
        .attr("x2", (d) => d.target.x)
        .attr("y2", (d) => d.target.y)

      node.attr("cx", (d) => d.x).attr("cy", (d) => d.y)
    })

    simulation.force("link").links(links) //.strength(5)

    // Draw links
    const link = svg
      .append("g")
      .attr("stroke", "#999")
      .attr("stroke-opacity", 0.8)
      .selectAll("line")
      .data(links)
      .join("line")
      .attr("stroke-width", 0.8)

    // Draw nodes
    const node = svg
      .append("g")
      .attr("stroke", "#fff")
      .attr("stroke-width", 0.5)
      .selectAll("circle")
      .data(nodes)
      .join("circle")
      .attr("r", (d) => {
        return Math.max(5, d.page_rank)
      })
      .attr("fill", (d) => {
        return d.color
      })
      .call(drag(simulation))

    node.append("title").text((d) => {
      return d.fileName
    })

    node.on("click", (event, node) => {
      window.location.href = node.url
    })

    // Drag functionality
    function drag(simulation) {
      function dragstarted(event, d) {
        if (!event.active) simulation.alphaTarget(0.3).restart()
        d.fx = d.x
        d.fy = d.y
      }

      function dragged(event, d) {
        d.fx = event.x
        d.fy = event.y
      }

      function dragended(event, d) {
        if (!event.active) simulation.alphaTarget(0)
        d.fx = null
        d.fy = null
      }

      return d3
        .drag()
        .on("start", dragstarted)
        .on("drag", dragged)
        .on("end", dragended)
    }
  }

  handleError(error) {
    console.error("Error in GraphController:", error)
  }

  sumOfPageRanks(pages) {
    if (this.titleIdValue == "index") {
      return window.innerHeight
    }
    let sumOfPageRanks = pages.reduce((acc, page) => acc + page.page_rank, 0)
    sumOfPageRanks = Math.max(100, Math.min(500, sumOfPageRanks))

    return sumOfPageRanks
  }
}
