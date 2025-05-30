const Hooks = {
  Dialog: {
    mounted() {
      this.handleEvent("show_dialog", () => {
        this.el.showModal();
      });

      this.handleEvent("close_dialog", () => {
        this.el.close();
      });
    }
  }
};

export default Hooks; 