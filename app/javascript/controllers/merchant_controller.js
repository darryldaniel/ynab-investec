import {Controller} from "@hotwired/stimulus"
import SlimSelect from 'slim-select';

// Connects to data-controller="merchant"
export default class extends Controller {
    static targets = ["payeeSelect"]

    connect() {
        this.payeeSelectTargets.forEach(target => {
            new SlimSelect({
                select: target
            })
        });
    }
}
