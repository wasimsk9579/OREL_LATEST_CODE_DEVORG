import { LightningElement,api } from 'lwc';

export default class OrlCustomPicklist extends LightningElement {
    @api options;
    @api value;
}