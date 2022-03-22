import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'dimensions', 'rules', 
    'cellsContainer', 'cells',
    'generation'
  ]
  static values = {
    width: Number, height: Number,
    rules: String, generations: Number,
    generation: Number, maxGeneration: Number
  }

  connect(){
    this.render()
  }

  render() {
    this.renderFields()
    this.renderGeneration()
  }

  renderFields(){
    this.dimensionsTarget.innerHTML = `<span>Size: </span>
                                       <input type="number" name="width" min=0 max=100
                                              value=${this.widthValue} data-action="input->world#changeDimension"
                                       ></input>
                                       <span>X</span>
                                       <input type="number" name="height" min=0 max=100
                                              value=${this.heightValue} data-action="input->world#changeDimension"
                                       ></input>`
    this.rulesTarget.innerHTML = `<span>Rulestring: </span>
                                  <input type="text" name="rules" pattern="B[\d]+\/S[\d]+"
                                         value="${this.rulesValue}" data-action="input->world#changeRules"
                                  ></input>`
  }

  changeDimension(e){
    let dimensionName = e.target.getAttribute('name')
    let dimensionValue = e.target.value

    this[`${dimensionName}Value`] = dimensionValue

    this.renderGeneration()
  }

  changeRules(e){
    let rulestring = e.target.value

    this.rulesValue = rulestring
  }

  changeGenerations(e){
    let gensNum = e.target.value

    this.generationsValue = gensNum
  }

  changeGeneration(e){
    let genNum = e.target.value

    this.renderGeneration(genNum)
  }

  playbackGeology(e){
    let state = e.target.classList.contains('paused') ? 'paused' : 'playback'

    switch(state){
      case 'paused': {
        if(this.playbackLoop) return false

        this.playbackLoop = setInterval(()=>{
          if (this.generationValue < this.maxGenerationValue){
            this.renderGeneration(this.generationValue + 1)
          } else {
            this.renderGeneration(0)
          }
        }, 500)
        e.target.classList.remove('paused')
        e.target.classList.add('playback')
        break
      }
      case 'playback': {
        clearInterval(this.playbackLoop)
        this.playbackLoop = null
        e.target.classList.remove('playback')
        e.target.classList.add('paused')
        break
      }
    }
  }

  renderGeneration(num){
    if(num != undefined) this.generationValue = num

    let cellsData = db.world.geology[num] || []

    let scale = 20

    let cells = `<canvas id="canvas" 
                      width=${scale*this.widthValue} 
                      height=${scale*this.heightValue} 
                      data-action="click->world#clickCanvas"
                 ></canvas>`

    this.cellsContainerTarget.innerHTML = cells

    this.canvas = this.cellsContainerTarget.getElementsByTagName('canvas')[0].getContext('2d')
    this.canvas.scaleFactor = scale
    this.canvas.scale(this.canvas.scaleFactor, this.canvas.scaleFactor)
    this.canvas.width = scale*this.widthValue
    this.canvas.height = scale*this.heightValue

    for(let y = 0; y < this.heightValue; y++){
      for(let x = 0; x < this.widthValue; x++){
        let state = (cellsData[y] && cellsData[y][x] || false) == 1 ? true : false

        this.setCellState(x, y, state)
        
      }
    }

    if(db.world.geology.length > 0){
      this.generationTarget.innerHTML = `<input class="generation-num-slider" type="range" 
                                          min=0 max=${this.maxGenerationValue} value=${this.generationValue}
                                          data-action="input->world#changeGeneration"
                                         ></input>
                                         <span class="generation-num">${this.generationValue}</span>
                                         <button class="geology-playback paused"
                                          data-action="click->world#playbackGeology"
                                         ></button>`
    } else {
      this.generationTarget.innerHTML = ''
    }
  }

  randomize(){
    for(let y = 0; y < this.heightValue; y++){
      for(let x = 0; x < this.widthValue; x++){
        let state = (Math.floor(Math.random()*2) == 1)

        this.setCellState(x, y, state)
      }
    }
  }

  clickCanvas(e){
    let canvas = e.target

    let x = Math.floor((e.clientX - canvas.getBoundingClientRect().left) / this.canvas.scaleFactor)
    let y = Math.floor((e.clientY - canvas.getBoundingClientRect().top) / this.canvas.scaleFactor)

    this.setCellState(x, y, !this.getCellState(x, y))
  }

  getCellState(x, y){
    return this.canvas.getImageData(x*this.canvas.scaleFactor, y*this.canvas.scaleFactor, 1, 1).data[3] == 255
  }

  setCellState(x, y, state){
    if(state){
      this.canvas.fillStyle = "rgb(0,0,0)";
      this.canvas.fillRect (x, y, 1, 1);      
    }else{
      this.canvas.clearRect (x, y, 1, 1);      
    }
  }

  submit(){
    let params = {}

    for(let y = 0; y < this.heightValue; y++){
      for(let x = 0; x < this.widthValue; x++){
        let cellState = this.getCellState(x, y) ? 1 : 0

        params.cells ||= []
        params.cells[y] ||= []
        params.cells[y][x] ||= cellState
      }
    }

    params.generations = this.generationsValue || 10
    params.rules = this.rulesValue

    fetch(
      '/api/world',
      {
        method: 'POST',
        body: JSON.stringify(params)
      }
    ).then((resp)=>resp.json())
     .then((json)=>{
       db.world = json.world

       this.widthValue = db.world.width
       this.heightValue = db.world.height
       this.rulesValue = db.world.rules
       this.generationValue = 0
       this.maxGenerationValue = db.world.geology.length - 1

       this.render()
       this.renderGeneration(0)
     })
  }
}