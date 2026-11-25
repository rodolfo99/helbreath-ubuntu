import { CharacterAttribute, type StartingAttributes } from '../proto/generated/network';

export const attributes: [keyof StartingAttributes, CharacterAttribute, string, string][] = [
    ['strength', CharacterAttribute.ATTRIBUTE_STRENGTH, 'Fuerza', '+1 daño cuerpo a cuerpo'],
    ['vitality', CharacterAttribute.ATTRIBUTE_VITALITY, 'Vitalidad', '+10 HP'],
    ['dexterity', CharacterAttribute.ATTRIBUTE_DEXTERITY, 'Destreza', '+1 daño con arco'],
    ['intelligence', CharacterAttribute.ATTRIBUTE_INTELLIGENCE, 'Inteligencia', '+5 maná'],
    ['magicPower', CharacterAttribute.ATTRIBUTE_MAGIC, 'Poder mágico', '+1 daño directo de hechizo'],
];
