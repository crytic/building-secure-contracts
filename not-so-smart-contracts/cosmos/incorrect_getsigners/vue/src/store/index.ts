import { createStore } from 'vuex'

import init from './config'

const store = createStore({
  state() {
    return {}
  },
  mutations: {},
  actions: {}
})
init(store)
export default store
